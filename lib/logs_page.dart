import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test/widgets/loading_wrapper.dart';
import 'login_screen.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage>
    with TickerProviderStateMixin {

  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final ScrollController _scrollController = ScrollController();

  Map<String, Color> _playerColors = {};
  Map<String, Color> _cityColors = {};
  int _coins = 0;
  bool _coinsLoaded = false;

  String get lobbyCode => LobbySession.lobbyCode;

  @override
  void initState() {
    super.initState();
    _listenToPlayers();
    _listenToCities();
  }

  // ================= PLAYERS =================
  void _listenToPlayers() {
    _db.child('lobbies/$lobbyCode/players').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      final Map<String, Color> colors = {};
      int myCoins = _coins;

      data.forEach((uid, player) {
        if (player is Map) {
          final name = player['name']?.toString();
          final colourInt = player['colour'];

          if (name != null && colourInt is int) {
            colors[name] = Color(colourInt);
          }

          if (uid == FirebaseAuth.instance.currentUser?.uid) {
            myCoins = player['coins'] ?? _coins;
          }
        }
      });

      setState(() {
        _playerColors = colors;
        _coins = myCoins;
        _coinsLoaded = true;
      });
    });
  }

  // ================= CITIES =================
  void _listenToCities() {
    _db.child('lobbies/$lobbyCode/cities').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      final Map<String, Color> colors = {};

      data.forEach((cityName, cityData) {
        if (cityData is Map && cityData['color'] is int) {
          colors[cityName] = Color(cityData['color']);
        }
      });

      setState(() {
        _cityColors = colors;
      });
    });
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final logsRef =
        FirebaseDatabase.instance.ref('lobbies/$lobbyCode/logs');

    return LoadingWrapper(
      isLoaded: _coinsLoaded,
      child: Scaffold(
        backgroundColor: Colors.green[50],
        body: Column(
          children: [
            // 🔷 TOP BAR (UNCHANGED)
            Container(
              height: 70,
              width: double.infinity,
              color: Colors.indigo,
              alignment: Alignment.center,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$_coins 🪙',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
      
            // 📜 LOGS
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: logsRef.orderByChild('timestamp').onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const Center(
                      child: Text(''),
                    );
                  }
      
                  final map =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
      
                  final logs = map.values.toList();
      
                  // Sort oldest → newest
                  logs.sort((a, b) =>
                      (a['timestamp'] ?? 0)
                          .compareTo(b['timestamp'] ?? 0));
      
                  // Scroll after frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
      
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final text = logs[index]['text'] ?? '';
                      final words = text.split(' ');
      
                      return TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        tween: Tween(begin: 0, end: 1),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          margin:
                              const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              children:
                                  words.map<InlineSpan>((word) {
                                final cleanWord = word
                                    .replaceAll(
                                        RegExp(r'[^\w]'), '');
      
                                if (_playerColors
                                    .containsKey(cleanWord)) {
                                  return TextSpan(
                                    text: '$word ',
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      color: _playerColors[
                                          cleanWord],
                                    ),
                                  );
                                }
      
                                if (_cityColors
                                    .containsKey(cleanWord)) {
                                  return TextSpan(
                                    text: '$word ',
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      color: _cityColors[
                                          cleanWord],
                                    ),
                                  );
                                }
      
                                return TextSpan(
                                    text: '$word ');
                              }).toList(),
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
    );
  }
}

