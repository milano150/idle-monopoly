import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PlayerListPage extends StatefulWidget {
  final String playerId;
  final String lobbyCode;

  const PlayerListPage({
    super.key,
    required this.playerId,
    required this.lobbyCode,
  });

  @override
  State<PlayerListPage> createState() => _PlayerListPageState();
}

class _PlayerListPageState extends State<PlayerListPage> {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  bool showPlayers = true;

  List<Map<String, dynamic>> players = [];
  List<Map<String, dynamic>> properties = [];

  @override
  void initState() {
    super.initState();
    listenToLobby();
  }

  // ---------------- STATE COLORS ----------------
  Color getStateColor(String state) {
  switch (state.toLowerCase()) {
    case 'kerala':
      return Colors.green[700]!;

    case 'tamil nadu':
      return Colors.red[700]!;

    case 'karnataka':
      return Colors.blue[700]!;

    case 'maharashtra':
      return Colors.orange[800]!;

    case 'andhra pradesh':
      return Colors.cyan[700]!;

    case 'telangana':
      return Colors.pink[600]!;

    case 'goa':
      return Colors.teal[600]!;

    case 'gujarat':
      return Colors.deepOrange[700]!;

    case 'rajasthan':
      return Colors.brown[600]!;

    case 'punjab':
      return Colors.yellow[800]!;

    case 'haryana':
      return Colors.lime[700]!;

    case 'uttar pradesh':
      return Colors.indigo[700]!;

    case 'bihar':
      return Colors.deepPurple[600]!;

    case 'west bengal':
      return Colors.redAccent[700]!;

    case 'odisha':
      return Colors.orangeAccent[700]!;

    case 'jharkhand':
      return Colors.greenAccent[700]!;

    case 'chhattisgarh':
      return Colors.blueGrey[600]!;

    case 'madhya pradesh':
      return Colors.amber[800]!;

    case 'assam':
      return Colors.lightGreen[700]!;

    case 'meghalaya':
      return Colors.tealAccent[700]!;

    case 'manipur':
      return Colors.indigoAccent[400]!;

    case 'mizoram':
      return Colors.blueAccent[400]!;

    case 'nagaland':
      return Colors.deepOrangeAccent[400]!;

    case 'tripura':
      return Colors.purpleAccent[400]!;

    case 'arunachal pradesh':
      return Colors.cyanAccent[700]!;

    case 'sikkim':
      return Colors.green[500]!;

    case 'himachal pradesh':
      return Colors.lightBlue[600]!;

    case 'uttarakhand':
      return Colors.blue[400]!;

    case 'jammu and kashmir':
      return Colors.lightBlueAccent[400]!;

    case 'ladakh':
      return Colors.grey[500]!;

    case 'delhi':
      return Colors.red[900]!;

    case 'chandigarh':
      return Colors.cyan[500]!;

    case 'puducherry':
      return Colors.teal[400]!;

    case 'andaman and nicobar islands':
      return Colors.blueAccent[700]!;

    case 'lakshadweep':
      return Colors.lightBlueAccent[700]!;

    case 'dadra and nagar haveli and daman and diu':
      return Colors.orange[600]!;

    default:
      return Colors.grey[600]!;
  }
}


  // ---------------- BUILDING ----------------
  IconData? getBuildingIcon(String? building) {
    if (building == null) return null;
    switch (building.toLowerCase()) {
      case 'house':
        return Icons.home;
      case 'hotel':
        return Icons.hotel;
      case 'mall':
        return Icons.storefront;
      case 'apartment':
        return Icons.apartment;
      case 'resort':
        return Icons.beach_access;
      default:
        return null;
    }
  }

  String getBuildingName(String? building) {
  if (building == null) return '';
  switch (building.toLowerCase()) {
    case 'house': return 'House';
    case 'apartment': return 'Apartment';
    case 'mall': return 'Mall';
    case 'hotel': return 'Hotel';
    case 'resort': return 'Resort';
    default: return '';
    }
  }


  // ---------------- FIREBASE LISTENER ----------------
  void listenToLobby() {
    db.child('lobbies/${widget.lobbyCode}').onValue.listen((event) {
      final raw = event.snapshot.value;
      if (raw == null) return;

      final lobby = Map<String, dynamic>.from(raw as Map);
      final playersRaw = lobby['players'];
      final citiesRaw = lobby['cities'];

      if (playersRaw == null) return;

      final playersData = Map<String, dynamic>.from(playersRaw as Map);
      final citiesData =
          citiesRaw != null ? Map<String, dynamic>.from(citiesRaw as Map) : {};

      final List<Map<String, dynamic>> tempPlayers = [];
      final List<Map<String, dynamic>> tempProperties = [];

      // ---------- PLAYERS (UNCHANGED UI DATA) ----------
      playersData.forEach((uid, rawPlayer) {
        if (rawPlayer == null) return;

        final p = Map<String, dynamic>.from(rawPlayer as Map);
        final coins = int.tryParse(p['coins']?.toString() ?? '') ?? 0;
        final name =
            p['name']?.toString().trim().isNotEmpty == true ? p['name'] : 'Player';

        final color = Color(
          int.tryParse(p['colour']?.toString() ?? '') ??
              Colors.blue.value,
        );

        int cityValue = 0;
        citiesData.forEach((_, rawCity) {
          if (rawCity == null) return;
          final c = Map<String, dynamic>.from(rawCity as Map);
          if (c['owner'] == uid) {
            cityValue += int.tryParse(c['cost']?.toString() ?? '') ?? 0;
          }
        });

        tempPlayers.add({
          'uid': uid,
          'name': name,
          'colour': color,
          'coins': coins,
          'netWorth': coins + cityValue,
        });
      });

      tempPlayers.sort(
        (a, b) => b['netWorth'].compareTo(a['netWorth']),
      );

      // ---------- PROPERTIES (NEW LOGIC) ----------
      citiesData.forEach((cityKey, rawCity) {
      if (rawCity == null) return;

      final city = Map<String, dynamic>.from(rawCity as Map);

      final String cityName = cityKey.toString(); // <-- city name from key
      final String state = city['state']?.toString() ?? 'Unknown';
      final String ownerId = city['owner']?.toString() ?? '';
      final int rent = int.tryParse(city['rent']?.toString() ?? '') ?? 0;
      final String? building = city['building']?.toString();

      final ownerData = playersData[ownerId];
      final String ownerName =
          ownerData != null ? ownerData['name'] ?? 'Player' : 'Unowned';

      final bool isOwned = ownerId.isNotEmpty;

      tempProperties.add({
        'city': cityName,
        'state': state,
        'owner': ownerName,
        'rent': rent,
        'building': building,
        'isOwned': isOwned,
      });
    });


      // Owned first, highest rent first
      tempProperties.sort((a, b) {
        if (a['isOwned'] != b['isOwned']) {
          return a['isOwned'] ? -1 : 1;
        }
        return b['rent'].compareTo(a['rent']);
      });

      setState(() {
        players = tempPlayers;
        properties = tempProperties;
      });
    });
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Stack(
        children: [
          // ---------- TOP BAR (UNCHANGED STYLE) ----------
          SafeArea(
            bottom: false,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.indigo,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _toggleButton(
                          label: 'Players',
                          selected: showPlayers,
                          onTap: () =>
                              setState(() => showPlayers = true),
                        ),
                        _toggleButton(
                          label: 'Properties',
                          selected: !showPlayers,
                          onTap: () =>
                              setState(() => showPlayers = false),
                        ),
                      ],
                    ),
                  ),

                  // Count
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      showPlayers
                          ? '${players.length} Players'
                          : '${properties.length} Properties',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- CONTENT ----------
          Padding(
            padding: const EdgeInsets.only(top: 90),
            child: showPlayers
                ? _buildPlayersList()
                : _buildPropertiesList(),
          ),
        ],
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

  // ---------------- PLAYERS LIST (ORIGINAL UI) ----------------
  Widget _buildPlayersList() {
    if (players.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final p = players[index];
        final isYou = p['uid'] == widget.playerId;

        return Card(
          elevation: isYou ? 6 : 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: isYou
                ? BorderSide(
                    color: Colors.indigo.shade400,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          margin:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: p['colour'],
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              p['name'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isYou ? Colors.indigo : Colors.black,
              ),
            ),
            subtitle: Text('Coins: ${p['coins']} 🪙'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Net Worth',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '${p['netWorth']} 🪙',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- PROPERTIES LIST (UPGRADED) ----------------
  Widget _buildPropertiesList() {
    if (properties.isEmpty) {
      return const Center(child: Text('No properties yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final p = properties[index];
        final stateColor = getStateColor(p['state']);
        final icon = getBuildingIcon(p['building']);
        final buildingName = getBuildingName(p['building']);

        return Opacity(
          opacity: p['isOwned'] ? 1 : 0.45,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: stateColor, width: 2),
            ),
            margin:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: icon != null
                  ? Icon(icon, size: 36, color: stateColor)
                  : const SizedBox(width: 36),
              title: Text(
                p['city'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                p['isOwned']
                    ? 'Owner: ${p['owner']}'
                    : 'Unowned',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (buildingName.isNotEmpty)
                    Text(
                      buildingName,
                      style: const TextStyle(fontSize: 12),
                    ),
                  Text(
                    '${p['rent']} 🪙',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
