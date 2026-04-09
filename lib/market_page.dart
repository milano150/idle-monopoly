import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'widgets/create_auction_modal.dart';
import 'services/log_service.dart';
import 'widgets/trade_builder_modal.dart';


class MarketPage extends StatefulWidget {
  final String playerId;
  final String lobbyCode;

  const MarketPage({
    super.key,
    required this.playerId,
    required this.lobbyCode,
  });

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  bool showPublic = true;
  int coins = 0;
  List<Map<String, dynamic>> ownedCities = [];
  String playerName = 'Player';
  static const int auctionDurationMs = 5000; //30 * 60 * 1000; // 30 minutes



  Color getCityColor(Map<String, dynamic> cityData) {
  if (cityData['color'] != null) {
    return Color(cityData['color']);
  }
  return Colors.grey;
}




  List<Map<String, dynamic>> publicAuctions = [];
  List<Map<String, dynamic>> privateTrades = [];

  DatabaseReference get lobbyRef =>
      db.child('lobbies/${widget.lobbyCode}');

  DatabaseReference get playerRef =>
      lobbyRef.child('players/${widget.playerId}');

  void _listenToOwnedCities() {
    lobbyRef.child('cities').onValue.listen((event) {
      final raw = event.snapshot.value as Map?;
      if (raw == null) return;

      final List<Map<String, dynamic>> temp = [];

      raw.forEach((cityName, data) {
        if (data is! Map) return;

        if (data['owner'] == widget.playerId &&
            data['inMarket'] != true &&
    data['building'] == null  ) {
          temp.add({
            'name': cityName,
          });
        }
      });

      setState(() {
        ownedCities = temp;
      });
    });
  }
  String getCountdown(int lastBidAt) {
    const int limitMs = auctionDurationMs; 
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int remaining = limitMs - (now - lastBidAt);

    if (remaining <= 0) return '00:00';

    final int minutes = (remaining ~/ 60000);
    final int seconds = (remaining % 60000) ~/ 1000;

    return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
  }


  void _openCreateAuctionModal({
    required String cityName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return CreateAuctionModal(
          lobbyCode: widget.lobbyCode,
          cityName: cityName,
          sellerId: widget.playerId,
          sellerName: playerName, 
        );
      },
    );
  }

  Future<void> _placeBid(Map<String, dynamic> auction) async {
    final auctionRef =
        lobbyRef.child('market/${auction['id']}');

    final now = DateTime.now().millisecondsSinceEpoch;
    const int bidAmount = 50;

    final int currentBid =
        int.tryParse(auction['currentBid']?.toString() ?? '0') ?? 0;

    final int newBid = currentBid + bidAmount;

    // 🚫 Seller cannot bid
    if (auction['sellerId'] == widget.playerId) {
      return;
    }

    // 🚫 Must have enough coins to support the FULL bid
    if (coins < newBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins to place this bid'),
        ),
      );
      return;
    }

    // 🔒 Update auction atomically
    String? previousHighestBidderId;
    String? previousHighestBidderName;

    final result = await auctionRef.runTransaction((data) {
      if (data == null) return Transaction.abort();

      final Map<String, dynamic> a =
          Map<String, dynamic>.from(data as Map);

      final int dbCurrentBid =
          int.tryParse(a['currentBid']?.toString() ?? '0') ?? 0;

      final int dbLastBidAt =
          int.tryParse(a['lastBidAt']?.toString() ?? '0') ?? 0;

      if (DateTime.now().millisecondsSinceEpoch - dbLastBidAt >= auctionDurationMs) {
        return Transaction.abort();
      }

      // 🔥 capture previous bidder BEFORE replacing
      previousHighestBidderId = a['highestBidderId'];
      previousHighestBidderName = a['highestBidderName'];

      final int updatedBid = dbCurrentBid + 50;

      return Transaction.success({
        ...a,
        'currentBid': updatedBid,
        'highestBidderId': widget.playerId,
        'highestBidderName': playerName,
        'lastBidAt': DateTime.now().millisecondsSinceEpoch,
      });
    });


    if (!result.committed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bid failed. Try again.'),
        ),
      );
    }
    if (result.committed &&
      previousHighestBidderId != null &&
      previousHighestBidderId != widget.playerId) {

      await lobbyRef
          .child('notifications/$previousHighestBidderId')
          .push()
          .set({
        'text': 'You were outbid on ${auction['city']}!',
        'color': Colors.red.value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

  }




  Future<void> resolveExpiredAuctions() async {
    final snap = await lobbyRef.child('market').get();
    if (!snap.exists) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    final data = Map<String, dynamic>.from(snap.value as Map);

    for (final entry in data.entries) {
      final auctionId = entry.key;
      final a = Map<String, dynamic>.from(entry.value);

      final int lastBidAt =
          int.tryParse(a['lastBidAt']?.toString() ?? '') ?? 0;

      if (lastBidAt == 0) continue;

      if (now - lastBidAt >= auctionDurationMs) {
        await _finalizeAuction(auctionId, a);
      }
    }
  }

  Future<void> _finalizeAuction(
    String auctionId,
    Map<String, dynamic> a,
  ) async {

    final auctionRef = lobbyRef.child('market/$auctionId');

    // 🔒 LOCK AUCTION FIRST
    final lockResult = await auctionRef.runTransaction((data) {
      if (data == null) return Transaction.abort();

      final map = Map<String, dynamic>.from(data as Map);

      if (map['status'] == 'closed') {
        return Transaction.abort(); // already processed
      }

      map['status'] = 'closed';
      return Transaction.success(map);
    });

    if (!lockResult.committed) return; // someone else processed it

    // ---------------------------
    // Now SAFE to finalize
    // ---------------------------

    final updatedAuction =
        Map<String, dynamic>.from(lockResult.snapshot.value as Map);

    final String city = updatedAuction['city'];
    final String sellerId = updatedAuction['sellerId'];
    final String sellerName = updatedAuction['sellerName'] ?? 'Player';
    final String? buyerId = updatedAuction['highestBidderId'];
    final String? buyerName = updatedAuction['highestBidderName'];
    final int price =
        int.tryParse(updatedAuction['currentBid']?.toString() ?? '0') ?? 0;

    if (buyerId == null || price <= 0) {
      await lobbyRef.child('cities/$city').update({
        'inMarket': false,
      });

      await auctionRef.remove();
      return;
    }

    final buyerCoinsRef =
        lobbyRef.child('players/$buyerId/coins');

    final sellerCoinsRef =
        lobbyRef.child('players/$sellerId/coins');

    final deductResult =
        await buyerCoinsRef.runTransaction((value) {
          final int current = (value as int?) ?? 0;
          return Transaction.success(current - price);
    });

    if (!deductResult.committed) {
      await lobbyRef.child('cities/$city').update({
        'inMarket': false,
      });

      await auctionRef.remove();
      return;
    }

    await sellerCoinsRef.runTransaction((value) {
      final int current = (value as int?) ?? 0;
      return Transaction.success(current + price);
    });

    await lobbyRef.child('cities/$city').update({
      'owner': buyerId,
      'inMarket': false,
    });

    //notify buyer
    await lobbyRef
        .child('notifications/$buyerId')
        .push()
        .set({
      'text': 'You won $city for $price 🪙',
      'color': Colors.green.value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    //notify seller
    await lobbyRef
      .child('notifications/$sellerId')
      .push()
      .set({
    'text': '$city was sold for $price 🪙 to $buyerName',
    'color': Colors.blue.value,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });



    await auctionRef.remove();

    await LogService.add(
      lobbyCode: widget.lobbyCode,
      text:
          '$city was sold to $buyerName for $price 🪙 via auction',
    );
  }



  void _openCreateAuction() {
    if (ownedCities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available cities to auction'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          children: [
            const Text(
              'Select Property',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...ownedCities.map((city) {
              return ListTile(
                title: Text(city['name']),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _openCreateAuctionModal(
                    cityName: city['name'],
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _listenToPlayerName() {
    playerRef.child('name').onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == null) return;

      setState(() {
        playerName = value.toString();
      });
    });
  }




  @override
  void initState() {
    super.initState();
    _listenToCoins();
    _listenToMarket();
    _listenToOwnedCities();
    resolveExpiredAuctions();
    _listenToPlayerName();
    _listenToTrades();
    // 🔁 redraw every second for countdown
    Stream.periodic(const Duration(seconds: 1)).listen((_) async {
      if (!mounted) return;

      final now = DateTime.now().millisecondsSinceEpoch;

      for (final a in publicAuctions) {
        final int lastBidAt =
            int.tryParse(a['lastBidAt']?.toString() ?? '') ?? 0;

        if (lastBidAt == 0) continue;

        if (now - lastBidAt >= auctionDurationMs) {
          await _finalizeAuction(a['id'], a);
        }
      }

      setState(() {});
    });

  }

  // ---------------- COINS ----------------
  void _listenToCoins() {
    playerRef.child('coins').onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == null) return;

      setState(() {
        coins = int.tryParse(value.toString()) ?? 0;
      });
    });
  }

  // ---------------- MARKET DATA ----------------
  void _listenToMarket() {
    lobbyRef.child('market').onValue.listen((event) {
      final raw = event.snapshot.value as Map?;
      if (raw == null) {
        setState(() {
          publicAuctions = [];
          privateTrades = [];
        });
        return;
      }

      final List<Map<String, dynamic>> pub = [];
      final List<Map<String, dynamic>> priv = [];

      raw.forEach((id, data) {
        if (data is! Map) return;

        final item = Map<String, dynamic>.from(data);
        item['id'] = id;

        if (item['type'] == 'public') {
          pub.add(item);
        } else if (item['type'] == 'private') {
          priv.add(item);
        }
      });

      setState(() {
        publicAuctions = pub;
        privateTrades = priv;
      });
    });
  }

  Future<void> createPrivateTrade({
    required String targetPlayerId,
    required String targetPlayerName,
    required List<String> myProperties,
    required List<String> theirProperties,
    required int myCoins,
    required int theirCoins,
  }) async {
    final tradeRef = lobbyRef.child('trades').push();

    await tradeRef.set({
      'type': 'private',
      'status': 'pending',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'playerA': {
        'id': widget.playerId,
        'name': playerName,
        'coins': myCoins,
        'properties': myProperties,
      },
      'playerB': {
        'id': targetPlayerId,
        'name': targetPlayerName,
        'coins': theirCoins,
        'properties': theirProperties,
      }
    });

    // 🔔 notify target player
    await lobbyRef
        .child('notifications/$targetPlayerId')
        .push()
        .set({
      'text': '$playerName sent you a trade request',
      'color': Colors.orange.value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

  }

  Future<void> acceptTrade(String tradeId) async {
    final tradeRef = lobbyRef.child('trades/$tradeId');

    final tradeSnap = await tradeRef.get();
    if (!tradeSnap.exists) return;

    final trade =
        Map<String, dynamic>.from(tradeSnap.value as Map);

    if (trade['status'] != 'pending') return;

    final playerA =
        Map<String, dynamic>.from(trade['playerA']);
    final playerB =
        Map<String, dynamic>.from(trade['playerB']);

    final String playerAId = playerA['id'];
    final String playerBId = playerB['id'];

    // Only participants can accept
    if (widget.playerId != playerAId &&
        widget.playerId != playerBId) {
      return;
    }

    final int playerACoins =
        int.tryParse(playerA['coins'].toString()) ?? 0;
    final int playerBCoins =
        int.tryParse(playerB['coins'].toString()) ?? 0;

    final List<String> propertiesA =
        List<String>.from(playerA['properties'] ?? []);
    final List<String> propertiesB =
        List<String>.from(playerB['properties'] ?? []);

    // 🔎 VERIFY COINS

    final snapA =
        await lobbyRef.child('players/$playerAId/coins').get();
    final snapB =
        await lobbyRef.child('players/$playerBId/coins').get();

    final int currentACoins =
        (snapA.value as int?) ?? 0;

    final int currentBCoins =
        (snapB.value as int?) ?? 0;


    
    
    // 🔎 VERIFY COINS (only if they are actually giving money)

    // Only check the player who is actually sending coins

  if (playerACoins > 0) {
    if (currentACoins < playerACoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Player A does not have enough money"),
        ),
      );
      return;
    }
  }

  if (playerBCoins > 0) {
    if (currentBCoins < playerBCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Player B does not have enough money"),
        ),
      );
      return;
    }
  }





    // 🔎 VERIFY PROPERTY OWNERSHIP + STATE
    for (final city in propertiesA) {
      final snap =
          await lobbyRef.child('cities/$city').get();

      if (!snap.exists) return;

      final data =
          Map<String, dynamic>.from(snap.value as Map);

      final owner = data['owner']?.toString();
      final inMarket = data['inMarket'] == true;

      if (owner != playerAId || inMarket) {
        return;
      }
    }


    for (final city in propertiesB) {
      final snap =
          await lobbyRef.child('cities/$city').get();

      if (!snap.exists) return;

      final data =
          Map<String, dynamic>.from(snap.value as Map);

      final owner = data['owner']?.toString();
      final inMarket = data['inMarket'] == true;

      if (owner != playerBId || inMarket) {
        return;
      }
    }


    // 🧠 BUILD ATOMIC UPDATE
    final Map<String, dynamic> updates = {};

    // Coins
    updates[
        'lobbies/${widget.lobbyCode}/players/$playerAId/coins'] =
        currentACoins - playerACoins + playerBCoins;

    updates[
        'lobbies/${widget.lobbyCode}/players/$playerBId/coins'] =
        currentBCoins - playerBCoins + playerACoins;

    // Transfer properties
    for (final city in propertiesA) {
      updates[
          'lobbies/${widget.lobbyCode}/cities/$city/owner'] =
          playerBId;
    }

    for (final city in propertiesB) {
      updates[
          'lobbies/${widget.lobbyCode}/cities/$city/owner'] =
          playerAId;
    }



    // 🚀 ATOMIC EXECUTION
    await db.update(updates);
    await lobbyRef.child('trades/$tradeId').remove();


    await LogService.add(
      lobbyCode: widget.lobbyCode,
      text:
          'Private trade completed between ${playerA['name']} and ${playerB['name']}',
    );
  }

  Future<void> rejectTrade(String tradeId) async {
    await lobbyRef
        .child('trades/$tradeId/status')
        .set('closed');
  }

  Future<void> cancelTrade(String tradeId) async {
    final snap =
        await lobbyRef.child('trades/$tradeId').get();

    if (!snap.exists) return;

    final trade =
        Map<String, dynamic>.from(snap.value as Map);

    if (trade['status'] != 'pending') return;

    final playerA =
        Map<String, dynamic>.from(trade['playerA']);

    if (playerA['id'] != widget.playerId) return;

    await lobbyRef.child('trades/$tradeId').remove();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Trade cancelled"),
        ),
      );
    }
  }


  void _openTradeBuilder() async {
    final playersSnap =
        await lobbyRef.child('players').get();

    if (!playersSnap.exists) return;

    final players =
        Map<String, dynamic>.from(
            playersSnap.value as Map);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return TradeBuilderModal(
          lobbyCode: widget.lobbyCode,
          currentPlayerId: widget.playerId,
          currentPlayerName: playerName,
        );
      },
    );
  }

  void _listenToTrades() {
    lobbyRef.child('trades').onValue.listen((event) {
      final raw = event.snapshot.value as Map?;

      if (raw == null) {
        setState(() => privateTrades = []);
        return;
      }

      final List<Map<String, dynamic>> temp = [];

      raw.forEach((id, data) {
        if (data is! Map) return;

        final trade = Map<String, dynamic>.from(data);
        trade['id'] = id;

        final playerA = trade['playerA'];
        final playerB = trade['playerB'];

        final isParticipant =
            playerA != null &&
            playerB != null &&
            (playerA['id'] == widget.playerId ||
            playerB['id'] == widget.playerId);

        final isPending = trade['status'] == 'pending';

        if (isParticipant && isPending) {
          temp.add(trade);
        }
      });

      setState(() {
        privateTrades = temp;
      });
    });
  }







  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.indigo,
      child: Icon(
        showPublic ? Icons.add : Icons.add,
        color: Colors.white,
      ),
      onPressed: showPublic
          ? _openCreateAuction
          : _openTradeBuilder,
    ),

      body: Stack(
        children: [
          _buildTopBar(),
          Padding(
            padding: const EdgeInsets.only(top: 90),
            child: showPublic
                ? _buildPublicMarket()
                : _buildPrivateTrades(),
          ),
        ],
      ),
    );
  }

  // ---------------- TOP BAR ----------------
  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.indigo,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Toggle (same as ListPage)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _toggleButton(
                    label: 'Public',
                    selected: showPublic,
                    onTap: () => setState(() => showPublic = true),
                  ),
                  _toggleButton(
                    label: 'Private',
                    selected: !showPublic,
                    onTap: () => setState(() => showPublic = false),
                  ),
                ],
              ),
            ),

            // Coins
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$coins 🪙',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TOGGLE BUTTON ----------------
  Widget _toggleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.indigo : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // ================= PUBLIC MARKET =================
  Widget _buildPublicMarket() {
    if (publicAuctions.isEmpty) {
      return const Center(
        child: Text(
          '',
          style:
              TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: publicAuctions.length,
      itemBuilder: (context, index) {
        final a = publicAuctions[index];
        final bool isLeading =
            a['highestBidderId'] == widget.playerId;

        final bool hasLeader =
            a['highestBidderId'] != null;

        final int lastBidAt =
            int.tryParse(a['lastBidAt']?.toString() ?? '') ?? 0;



        final bool isSeller =
            a['sellerId'] == widget.playerId;

        final bool canBid =
            !isLeading && !isSeller && coins >= 50;


        final String? highestBidderName =
            a['highestBidderName'];




        return Card(
          elevation: isLeading ? 6 : 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isSeller
                  ? Colors.orange
                  : isLeading
                      ? Colors.green
                      : Colors.transparent,
              width: 2,
            ),

          ),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    a['city'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isSeller)
                  const Icon(Icons.store, color: Colors.orange),
                if (isLeading)
                  const Icon(Icons.star, color: Colors.green),

              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seller: ${a['sellerName']}'),

                if (isSeller)
                  const Text(
                    "You're the seller",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                if (highestBidderName != null)
                  Text(
                    'Highest Bidder: $highestBidderName',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(Icons.timer, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      getCountdown(lastBidAt),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: getCountdown(lastBidAt) == '00:00'
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ],
                ),

                if (isLeading && !isSeller)
                  const Text(
                    'You are leading',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Bid'),
                    Text(
                      '${a['currentBid']} 🪙',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: canBid ? () => _placeBid(a) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: canBid ? Colors.indigo : Colors.grey[400],
                      borderRadius: BorderRadius.circular(10), // squarish
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

              ],
            ),
          ),
        );

      },
    );
  }

  // ================= PRIVATE TRADES =================
  Widget _buildPrivateTrades() {
    if (privateTrades.isEmpty) {
      return const Center(
        child: Text(
          'No private trades!',
          style:
              TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: privateTrades.length,
      itemBuilder: (context, index) {
        final t = privateTrades[index];

        final playerA =
            Map<String, dynamic>.from(t['playerA']);
        final playerB =
            Map<String, dynamic>.from(t['playerB']);

        final String playerAId = playerA['id'];
        final String playerBId = playerB['id'];

        final bool isCreator =
            widget.playerId == playerAId;

        final bool isOtherSide =
            widget.playerId == playerBId;

        final bool isPending =
            t['status'] == 'pending';

        final List propertiesA =
            playerA['properties'] is List
                ? List.from(playerA['properties'])
                : [];

        final List propertiesB =
            playerB['properties'] is List
                ? List.from(playerB['properties'])
                : [];

        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 4),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [

                // Title
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TRADE OFFER",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (isPending)
                      const Text(
                        "PENDING",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // TABLE LAYOUT
                Row(
                  children: [
                    Expanded(
                      child: _buildTradeSide(
                        playerName: playerA['name'],
                        coins: playerA['coins'],
                        properties: propertiesA,
                        highlight:
                            widget.playerId == playerAId,
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12),
                      child: Icon(
                        Icons.swap_horiz,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),

                    Expanded(
                      child: _buildTradeSide(
                        playerName: playerB['name'],
                        coins: playerB['coins'],
                        properties: propertiesB,
                        highlight:
                            widget.playerId == playerBId,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                if (isPending && isOtherSide)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              acceptTrade(t['id']),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                          ),
                          child:
                              const Text("Accept"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              rejectTrade(t['id']),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                          ),
                          child:
                              const Text("Decline"),
                        ),
                      ),
                    ],
                  ),

                if (isPending && isCreator)
                  Column(
                    children: [
                      const Text(
                        "Waiting for other player...",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => cancelTrade(t['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Cancel Trade", style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ],
                  ),

              ],
            ),
          ),
        );

      },
    );
  }
  
  Widget _buildTradeSide({
    required String playerName,
    required dynamic coins,
    required List properties,
    required bool highlight,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.indigo[50]
            : Colors.grey[100],
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? Colors.indigo
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            "$playerName gives",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "$coins 🪙",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          if (properties.isEmpty)
            const Text(
              "No properties",
              style: TextStyle(
                color: Colors.grey,
              ),
            )
          else
            ...properties.map((city) {
              return FutureBuilder(
                future: db
                    .child('lobbies/${widget.lobbyCode}/cities/$city')
                    .get(),
                builder: (context, snap) {
                  if (!snap.hasData || !snap.data!.exists) {
                    return const SizedBox();
                  }

                  final cityData =
                      Map<String, dynamic>.from(snap.data!.value as Map);

                  final color = cityData['color'] != null
                    ? Color(cityData['color'])
                    : Colors.grey;


                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      city,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              );
            }).toList(),

        ],
      ),
    );
  }


}
