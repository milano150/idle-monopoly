import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:test/firebase_options.dart';
import 'properties.dart';
import 'map.dart';
import 'services/auth_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'auth_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'listpage.dart';
import 'dart:ui';
import 'logs_page.dart';
import 'services/log_service.dart';
import 'market_page.dart';
import 'package:test/data/map_model.dart';
import 'package:test/data/map_registry.dart';
import 'services/global_notification_service.dart';







void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.signOut(); //TEMPORARY LOG OUT EVERY RESTART

  runApp(const MyApp());
}




IconData getBuildingIcon(String building) {
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


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final String playerId;
  const MainScaffold({super.key, required this.playerId});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 2; //main page

  void _listenToGlobalEvents() {
    final myId = widget.playerId;

    final notiRef = FirebaseDatabase.instance
        .ref()
        .child('lobbies/${LobbySession.lobbyCode}/notifications/$myId');

    notiRef.onChildAdded.listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      final text = data['text']?.toString() ?? '';
      final colorValue = data['color'];

      GlobalNotificationService.show(
        text,
        color: Color(colorValue ?? Colors.blue.value),
      );

      // 🔥 remove after showing (one-time popup)
      await event.snapshot.ref.remove();
    });
  }

  @override
  void initState() {
    super.initState();
    _listenToGlobalEvents();
  }



  @override
  Widget build(BuildContext context) {
    
    final List<Widget> pages = [
      MarketPage(playerId: widget.playerId, lobbyCode: LobbySession.lobbyCode), //market
      PropertiesPage(playerId: widget.playerId), //properties screen
      HomeScreen(playerId: widget.playerId), // dice screen
      PlayerListPage(playerId: widget.playerId, lobbyCode: LobbySession.lobbyCode,),//leaderboard
      const LogsPage(),//log
      //KeralaMapScreen(playerId: widget.playerId), // map screen
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: Colors.indigo,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shop),label: 'Market',),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.hourglass_bottom), label: 'Roll'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Lists'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long),label: 'Logs',),
        ],
      ),
    );
  }
}

// ===========================================================
// ROLL SCREEN :P
// ===========================================================
class HomeScreen extends StatefulWidget {
  final String playerId;
  const HomeScreen({super.key, required this.playerId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //inis

  bool isInDebt = false;
  bool _rolled = false;
  String city = '';
  String cityState = '';
  String? owner;
  bool canBuy = false;
  int coins = 5000; // default coins
  int cityRent = 0;
  String? landedBuilding;
  String? ownerName;
  int _ownerSpecialCount = 0;


  String playerName = 'Player';
  Color playerColor = Colors.blue;


  final Random random = Random();
  late DatabaseReference database;

  String get lobbyCode => LobbySession.lobbyCode;


  DatabaseReference get lobbyRef =>
    database.child('lobbies/$lobbyCode');

  DatabaseReference cityRef(String cityName) =>
    lobbyRef.child('cities/$cityName');

  DatabaseReference lobbyPlayerRef(String uid) =>
    lobbyRef.child('players/$uid');



  void listenToPlayerProfile() {
  database
    .child('lobbies/$lobbyCode/players/${widget.playerId}')
    .onValue
    .listen((event) {

    final data = event.snapshot.value as Map?;
    if (data == null) return;

    setState(() {
      playerName = data['name'] ?? 'Player';
      playerColor = Color(
        int.tryParse(data['colour']?.toString() ?? '') ??
            Colors.blue.value,
      );
    });
  });
  }
  void _openProfileEditor() {
    final nameController = TextEditingController(text: playerName);
    Color selectedColor = playerColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),
                  // color picker (simple preset row)
                  HueRingPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      setModalState(() => selectedColor = color);
                    },
                    enableAlpha: false,
                  ),





                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      await database
                      .child('lobbies/$lobbyCode/players/${widget.playerId}')
                      .update({
                      'name': nameController.text.trim(),
                      'colour': selectedColor.value,
                    });


                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,      
                      foregroundColor: Colors.black,       
                      side: BorderSide(color: Colors.black.withOpacity(0.8), width: 2),
                    ),
                    
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void listenToCoins() {
  lobbyPlayerRef(widget.playerId)
      .child('coins')
      .onValue
      .listen((event) {
    final value = event.snapshot.value;
    if (value == null) return;

    final newCoins = int.tryParse(value.toString()) ?? coins;

    setState(() {
      coins = newCoins;
      isInDebt = newCoins < 0; //checking for debt

    });
  });
  }

  

  List<CityModel> currentMap = [];

  Future<void> loadMap() async {
  final snap = await lobbyRef.child('map').get();
  final mapName = snap.value?.toString() ?? 'kerala';

  setState(() {
    currentMap = GameMapRegistry.getMap(mapName);
  });
  }

  Future<int> _countOwned(String ownerId, String type) async {
    final snap = await lobbyRef.child('cities').get();
    int count = 0;

    if (snap.exists) {
      final data = snap.value as Map;
      data.forEach((name, city) {
        if (city['owner'] == ownerId &&
            city['type'] == type) {
          count++;
        }
      });
    }

    return count;
  }


  



  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase.instance.ref();
    listenToPlayerProfile();
    listenToCoins();
    loadMap();

  }


  @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // =====================
            // MAIN GAME UI
            // =====================
            Column(
              children: [
                // TOP BAR
                Container(
                  height: 70,
                  width: double.infinity,
                  color: Colors.indigo,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // PLAYER PROFILE
                      InkWell(
                        onTap: _openProfileEditor,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: playerColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                playerName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // COINS
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$coins 🪙',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                // GAME CONTENT
                Expanded(
                  child: Center(
                    child: _rolled ? buildResultView() : buildRollButton(),
                  ),
                ),
              ],
            ),

            // =====================
            // 🔴 DEBT OVERLAY
            // =====================
            if (isInDebt)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Stack(
                    children: [
                      // 🔹 BLUR LAYER
                      BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 8, // blur strength (horizontal)
                          sigmaY: 8, // blur strength (vertical)
                        ),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),

                      // 🔴 RED TINT + CONTENT
                      Container(
                        color: const Color(0xFF8B0000).withOpacity(0.45),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.warning_rounded,
                              size: 90,
                              color: Colors.white,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'You are in debt.',
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Clear your balance to continue',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
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


  Widget buildRollButton() {
  return ElevatedButton(
    onPressed: isInDebt ? null : rollDice, // 🚫 blocked
    style: ElevatedButton.styleFrom(
      fixedSize: const Size(100, 100),
      backgroundColor: isInDebt
          ? Colors.red[300]
          : const Color(0xFFFFFBFB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black26, width: 2),
      ),
      elevation: 5,
    ),
    child: Text(
      isInDebt ? '💀' : '🎲',
      style: const TextStyle(fontSize: 28),
    ),
  );
}


  Widget buildResultView() {
    final selectedCity =
      currentMap.firstWhere((c) => c.name == city);

    final bool isSpecial =
        selectedCity.type == PropertyType.railway ||
        selectedCity.type == PropertyType.airport;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title
        const Text(
          'You landed on',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 16),

              // City card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
                decoration: BoxDecoration(
                  color: canBuy
                      ? Colors.green[600]
                      : owner == widget.playerId
                          ? Colors.amber[600]
                          : Colors.red[600],
                  borderRadius: isSpecial
                      ? BorderRadius.circular(0) // square-ish
                      : BorderRadius.circular(18), // normal city
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      city,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    if (isSpecial) ...[
                      const SizedBox(height: 8),
                      Icon(
                        selectedCity.type == PropertyType.railway
                            ? Icons.train
                            : Icons.flight,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ],
                ),
              ),


              const SizedBox(height: 20),
              if (landedBuilding != null) ...[
        const SizedBox(height: 16),
        Column(
          children: [
            Icon(
              getBuildingIcon(landedBuilding!),
              size: 48,
              color: Colors.black87,
            ),
            const SizedBox(height: 6),
            Text(
              landedBuilding!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
      if (!isSpecial)
        Text(
          'State: $cityState',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        // Ownership status
        Text(
          canBuy
              ? 'Available to buy'
              : owner == widget.playerId
                  ? 'Owned by you'
                  : 'Owned by $ownerName',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: canBuy
                ? Colors.green[700]
                : owner == widget.playerId
                    ? Colors.amber[800]
                    : Colors.red[700],
          ),
        ),

        if (!canBuy &&
          owner != widget.playerId &&
          _ownerSpecialCount > 0 &&
          isSpecial)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '$ownerName owns $_ownerSpecialCount ${selectedCity.type == PropertyType.airport ? "airports" : "railways"}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),


        const SizedBox(height: 28),

        // Cost / Rent info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            canBuy
                ? 'Cost: ${getCityCost(city)} 🪙'
                : 'Rent: $cityRent 🪙',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Buy button (only if available)
        if (canBuy)
          buildCustomButton(
            text: 'Buy City',
            color: Colors.green[800]!,
            onPressed: buyCity,
          ),

        const SizedBox(height: 16),

        // Roll again
        buildCustomButton(
          text: 'Roll Again',
          color: Colors.grey[800]!,
          onPressed: () {
            setState(() {
              _rolled = false;
              city = '';
              owner = null;
              canBuy = false;
            });
          },
        ),
      ],
    );
  }


  Widget buildCustomButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(180, 50),
        backgroundColor: const Color(0xFFFFFBFB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.8), width: 2),
        ),
        elevation: 5,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  int getCityCost(String cityName) {
  return currentMap
      .firstWhere((c) => c.name == cityName)
      .cost;
}


  Future<String> getUsername(String uid) async {
  final snap = await database
    .child('lobbies/$lobbyCode/players/$uid/name')
    .get();


  return snap.value?.toString() ?? 'Player';
  }


  void rollDice() async {
    if (currentMap.isEmpty) return;

    int randInt = random.nextInt(currentMap.length);
    CityModel selectedCity = currentMap[randInt];
    final cityName = selectedCity.name;


    final cityRef = this.cityRef(cityName);

    final String selectedState = selectedCity.state;


    DataSnapshot citySnapshot = await cityRef.get();
    Map cityDataFirebase = citySnapshot.value as Map? ?? {};
    final String? building =
        cityDataFirebase['building']?.toString();

    String? cityOwner =
        cityDataFirebase['owner']?.toString();

    int rent = int.tryParse(
          cityDataFirebase['rent']?.toString() ?? '',
        ) ??
        selectedCity.rent;

    String? fetchedOwnerName;
    final String? type = cityDataFirebase['type'];

    if (cityOwner != null &&
        cityOwner.isNotEmpty &&
        cityOwner != widget.playerId) {
        if (type == 'PropertyType.railway') {
            _ownerSpecialCount =
                await _countOwned(cityOwner, 'PropertyType.railway');
            rent = 50 * await _countOwned(cityOwner, 'PropertyType.railway');
            
          }

        if (type == 'PropertyType.airport') {
          _ownerSpecialCount =
              await _countOwned(cityOwner, 'PropertyType.airport');
          rent = 100 * await _countOwned(cityOwner, 'PropertyType.airport');
        }

        
      coins -= rent;
      await lobbyPlayerRef(widget.playerId)
          .child('coins')
          .set(coins);

      final ownerRef = lobbyPlayerRef(cityOwner);
      final ownerSnapshot = await ownerRef.get();

      int ownerCoins = int.tryParse(
            ownerSnapshot.child('coins').value?.toString() ?? '',
          ) ??
          5000;

      await ownerRef.child('coins').set(ownerCoins + rent);

      // 🔔 Send direct notification to owner
      await lobbyRef
          .child('notifications/$cityOwner')
          .push()
          .set({
        'text': '$playerName landed on $cityName (+$rent🪙)',
        'color': Colors.green.value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });


      fetchedOwnerName = await getUsername(cityOwner);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Paid $rent 🪙 rent to $fetchedOwnerName!',
          ),
        ),
      );

      await LogService.add(
        lobbyCode: lobbyCode,
        text: '$playerName landed on $cityName and paid $rent🪙 to $fetchedOwnerName',
      );
    }

    setState(() {
      city = cityName;
      owner = cityOwner;
      ownerName = fetchedOwnerName; // ✅ now valid
      canBuy = cityOwner == null || cityOwner.isEmpty;
      cityRent = rent;
      landedBuilding = building;
      _rolled = true;
      cityState = selectedState;

      if (type != 'PropertyType.railway' && type != 'PropertyType.airport') {
        _ownerSpecialCount = 0;
      }

    });
  }


  void buyCity() async {
    int cityCost = getCityCost(city);

    if (coins < cityCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins!')),
      );
      return;
    }

    final cityRef = this.cityRef(city);
    final cityModel =
    currentMap.firstWhere((c) => c.name == city);

    await cityRef.set({
      'owner': widget.playerId,
      'cost': cityModel.cost,
      'rent': cityModel.rent,
      'state': cityModel.state,
      'color': cityModel.color.value,
      'type': cityModel.type.toString(),
      'building': null,
      'baserent': cityModel.rent,
    });


    coins -= cityCost;
    await lobbyPlayerRef(widget.playerId).child('coins').set(coins);

    await LogService.add(
      lobbyCode: lobbyCode,
      text: '$playerName bought $city for $cityCost🪙',
    );

    setState(() {
      owner = widget.playerId;
      canBuy = false;
    });
  }
}
