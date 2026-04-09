import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'login_screen.dart';
import 'services/log_service.dart';



class PropertiesPage extends StatefulWidget {
  final String playerId;
  const PropertiesPage({super.key, required this.playerId});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _ownedCities = [];
  late PageController _pageController;
  int _coins = 0; // 👈 store coins here
  String _playerName = 'Player';


  final String lobbyCode = LobbySession.lobbyCode;


  DatabaseReference get lobbyRef =>
      _db.child('lobbies/$lobbyCode');

  DatabaseReference cityRef(String cityName) =>
      lobbyRef.child('cities/$cityName');

  DatabaseReference lobbyPlayerRef(String uid) =>
      lobbyRef.child('players/$uid');



  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _loadProperties();
    _listenToCoins();
    _listenToPlayerName();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _listenToCoins() {
    lobbyPlayerRef(widget.playerId).child('coins').onValue.listen((event) {
      final newCoins = event.snapshot.value;
      if (newCoins != null) {
        setState(() {
          _coins = int.tryParse(newCoins.toString()) ?? 0;
        });
      }
    });
  }

  void _listenToPlayerName() {
    lobbyPlayerRef(widget.playerId)
        .child('name')
        .onValue
        .listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        setState(() {
          _playerName = value.toString();
        });
      }
    });
  }


  void _loadProperties() {
    lobbyRef.child('cities').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        setState(() => _ownedCities = []);
        return;
      }

      final owned = <Map<String, dynamic>>[];
      data.forEach((cityName, cityData) {
        if (cityData is Map && cityData['owner'] == widget.playerId) {
          final entry = Map<String, dynamic>.from(cityData);
          entry['name'] = cityName;
          owned.add(entry);
        }
      });

      owned.sort((a, b) {
        final stateA = a['state']?.toString() ?? '';
        final stateB = b['state']?.toString() ?? '';
        return stateA.compareTo(stateB);
      });

      setState(() {
        _ownedCities = owned;
      });
    });
  }
  //alert system
  void _showSnack(String message, {Color? color}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

  //gotobuildings
  final Map<String, Map<String, num>> buildings = {
    'House': {'cost': 100, 'rm': 1.5},
    'Apartment': {'cost': 250, 'rm': 1.7},
    'Mall': {'cost': 300, 'rm': 2.5},
    'Hotel': {'cost': 700, 'rm': 3.5},
    'Resort': {'cost': 900, 'rm': 5},
  };


  void _showConstructMenu(Map<String, dynamic> city) {



    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Construct in ${city['name']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ...buildings.entries.map((entry) {
                final building = entry.key;
                final int cost = entry.value['cost'] as int;
                final rentMultiplier = entry.value['rm'];
                final newRent = city['rent'] * rentMultiplier;

                return ListTile(
                  leading: const Icon(Icons.apartment),
                  title: Text(building),
                  subtitle: Text(
                    'Cost: $cost 🪙  • Rent Multiplier: ${rentMultiplier}x •  New Rent: $newRent 🪙',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);

                    await _buildCity(
                      city: city,
                      building: building,
                      cost: cost,
                      rentMultiplier: rentMultiplier as double,
                    );
                  },

                );
              }),

            ],
          ),
        );
      },
    );
  }

  Future<void> _buildCity({
  required Map<String, dynamic> city,
  required String building,
  required int cost,
  required double rentMultiplier,
}) async {
  final cityName = city['name'];

  final playerCoinsRef =
    lobbyPlayerRef(widget.playerId).child('coins');
  final cityRef = this.cityRef(cityName);

  // get coins
  final coinSnap = await playerCoinsRef.get();
  int coins = int.tryParse(coinSnap.value.toString()) ?? 0;

  if (coins < cost) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not enough coins!')),
    );
    return;
  }

  // get base rent
  final int baseRent =
      int.tryParse(city['baserent']?.toString() ?? '0') ?? 0;

  final int newRent = (baseRent * rentMultiplier).round();

  // update DB
  await playerCoinsRef.set(coins - cost);
  await cityRef.update({
    'building': building,
    'rent': newRent,
  });

  await LogService.add(
    lobbyCode: lobbyCode,
    text: '$_playerName upgraded $cityName to $building',
  );

}


  IconData _getBuildingIcon(String building) {
  switch (building) {
    case 'House':
      return Icons.house;
    case 'Apartment':
      return Icons.apartment;
    case 'Mall':
      return Icons.storefront;
    case 'Hotel':
      return Icons.hotel;
    case 'Resort':
      return Icons.beach_access;
    default:
      return Icons.location_city;
  }
}

  Future<void> _destroyBuilding({
    required String cityName,
    required String building,
    required Map<String, dynamic> city,
  }) async {
    final playerCoinsRef =
    lobbyPlayerRef(widget.playerId).child('coins');
  final cityRef = this.cityRef(cityName);


    final int cost = buildings[building]!['cost'] as int;
    final int refund = (cost / 2).round();

 
    final coinSnap = await playerCoinsRef.get();
    int coins = int.tryParse(coinSnap.value.toString()) ?? 0;


    final int baseRent = int.tryParse(
          (city['baserent'] ?? city['rent']).toString(),
        ) ??
        0;

    
    await playerCoinsRef.set(coins + refund);

    await cityRef.update({
      'building': null,
      'rent': baseRent,
    });

    await LogService.add(
      lobbyCode: lobbyCode,
      text: '$_playerName destroyed $building in $cityName (+$refund 🪙)',
    );



    _showSnack(
      'Destroyed $building in $cityName (+$refund 🪙)',
      color: Colors.red[700],
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Column( 
        children: [
          // ---- Coins AppBar ----
          Container(
            height: 70,
            width: double.infinity,
            color: Colors.indigo,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                '$_coins 🪙', // 🔴 CHANGED: live coins
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          Expanded( 
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ---- Carousel ----
                  SizedBox(
                    height: 600, 
                    child: _ownedCities.isEmpty
                        ? const Center(
                            child: Text(
                              'No properties owned yet!',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black54),
                            ),
                          )
                        : AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, _) {
                              return PageView.builder(
                                controller: _pageController,
                                scrollDirection: Axis.vertical,
                                itemCount: _ownedCities.length,
                                itemBuilder: (context, index) {
                                  final city = _ownedCities[index];
                                  final cityName = city['name'];
                                  final state = city['state'] ?? 'Unknown';
                                  final rent = city['rent'] ?? '-';
                                  final cost = city['cost'] ?? '-';
                                  final String? building = city['building']?.toString();
                                  final bool hasBuilding = building != null;
                                  final bool inAuction = city['inMarket'] == true;

                                  final int baseRent = int.tryParse(
                                    (city['baserent'] ?? city['rent']).toString(),
                                  ) ??
                                  0;

                                  // 🎨 Color comes directly from DB (new architecture)
                                  Color topColor = city['color'] != null
                                      ? Color(city['color'])
                                      : Colors.grey[600]!;



                                  double value = 1.0;
                                  if (_pageController.position.haveDimensions) {
                                    value = _pageController.page! - index;
                                    value = (1 - (value.abs() * 0.3)).clamp(0.8, 1.0);
                                  } else if (_pageController.initialPage == index) {
                                    value = 1.0;
                                  } else {
                                    value = 0.8;
                                  }
                                  double opacity = max(0.5, value);

                                  return Transform.scale(
                                    scale: value,
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 24),
                                        child: Opacity(
                                          opacity: inAuction ? 0.85 : 1,
                                          child: Material(
                                            elevation: 6,
                                            borderRadius: BorderRadius.circular(16),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Container(
                                                    height: inAuction ? 32 : 50,
                                                    decoration: BoxDecoration(
                                                      color: topColor,
                                                      borderRadius:
                                                          const BorderRadius.vertical(
                                                        top: Radius.circular(16),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Center(
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                cityName,
                                                                style: const TextStyle(
                                                                  fontSize: 30,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                          
                                                              if (inAuction)
                                                                Container(
                                                                  margin: const EdgeInsets.only(top: 6),
                                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.orange[800],
                                                                    borderRadius: BorderRadius.circular(12),
                                                                  ),
                                                                  child: const Text(
                                                                    'IN AUCTION',
                                                                    style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.bold,
                                                                      letterSpacing: 1,
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                          
                                                        const SizedBox(height: 8),
                                                        Center(
                                                          child: Text(
                                                            state,
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                color: Colors.black54),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text('Cost: $cost 🪙',
                                                                style: const TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight:
                                                                        FontWeight.w600)),
                                                            Text('Base Rent: $baseRent 🪙',
                                                                style: const TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight:
                                                                        FontWeight.w600)),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 16),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text('Building: $building',
                                                                style: const TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight:
                                                                        FontWeight.w600)),
                                                            Text('Rent: $rent 🪙',
                                                                style: const TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight:
                                                                        FontWeight.w600)),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 16,),
                                                        Center(
                                                          child: Container(
                                                            height: 150,
                                                            width: 150,
                                                            margin:
                                                                const EdgeInsets.symmetric(
                                                                    vertical: 12),
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey[200],
                                                              borderRadius:
                                                                  BorderRadius.circular(8),
                                                              border: Border.all(
                                                                  color: Colors.black26),
                                                            ),
                                                            child: building == null ? const SizedBox(): Icon(_getBuildingIcon(building),size: 80,),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 16),
                                                        Center(
                                                          
                                                          child: 
                                          
                                                            ElevatedButton(
                                                              onPressed: inAuction
                                                                ? null
                                                                : hasBuilding
                                                                    ? () async {
                                                                        await _destroyBuilding(
                                                                          cityName: cityName,
                                                                          building: building!,
                                                                          city: city,
                                                                        );
                                                                      }
                                                                    : () => _showConstructMenu(city),

                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: inAuction
                                                                  ? Colors.grey[500]
                                                                  : hasBuilding
                                                                      ? const Color.fromARGB(255, 165, 12, 1)
                                                                      : topColor,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(12),
                                                                ),
                                                                padding: const EdgeInsets.symmetric(
                                                                  horizontal: 32,
                                                                  vertical: 12,
                                                                ),
                                                              ),
                                                              child: Text(
                                                                  inAuction
                                                                      ? 'In Auction'
                                                                      : hasBuilding
                                                                          ? 'Destroy'
                                                                          : 'Construct',

                                                                style: const TextStyle(
                                                                  fontSize: 18,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ),
                                          
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),


                 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
