import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

import 'services/player_service.dart';

/// Global session holder
class LobbySession {
  static String lobbyCode = '';
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _lobbyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _loading = false;
  String? _error;
  
  bool _isCreatingLobby = false;
  String _createLobbyCode = '';
  String _createSelectedMap = 'kerala';


  final List<Color> playerColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
    Colors.cyan,
    Colors.pink,
  ];

  final List<String> availableMaps = ['kerala', 'india','kerala_extended'];



  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = playerColors[Random().nextInt(playerColors.length)];
  }

  Future<void> _play() async {
    final code = _lobbyController.text.trim().toUpperCase();
    final name = _nameController.text.trim();

    if (code.isEmpty) {
      setState(() => _error = 'Enter lobby code');
      return;
    }

    if (name.isEmpty) {
      setState(() => _error = 'Enter player name');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 🔍 CHECK LOBBY EXISTS
      final lobbyRef =
          FirebaseDatabase.instance.ref('lobbies/$code');
      final snapshot = await lobbyRef.get();

      if (!snapshot.exists) {
        setState(() {
          _error = 'No lobby found';
          _loading = false;
        });
        return;
      }

      // ✅ SAVE SESSION
      LobbySession.lobbyCode = code;

      // 🔐 AUTH
      final cred = await FirebaseAuth.instance.signInAnonymously();
      final uid = cred.user!.uid;

      // 🌍 GLOBAL PLAYER
      await PlayerService.createGlobalPlayerIfNotExists(uid);

      // ✍️ UPDATE GLOBAL NAME + COLOR
      await FirebaseDatabase.instance.ref('players/$uid').update({
        'name': name,
        'colour': _selectedColor.value,
      });

      // 🎮 JOIN LOBBY
      await PlayerService.joinLobby(
        name: name,
        lobbyCode: code,
        uid: uid,
        colour: _selectedColor.value,
      );
    } catch (e) {
      setState(() {
        _error = 'Something went wrong';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }




  

    Widget _primaryButton(
  String text,
  VoidCallback onPressed, {
  Color color = Colors.blue,
}) {
  return SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      onPressed: _loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              
            ),
    ),
  );
}




  Future<void> _createLobbyCustom() async {
  final name = _nameController.text.trim();
  final code = _createLobbyCode;

  if (name.isEmpty) {
    setState(() => _error = 'Enter player name');
    return;
  }

  if (code.isEmpty) {
    setState(() => _error = 'Enter lobby code');
    return;
  }

  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final lobbyRef =
        FirebaseDatabase.instance.ref('lobbies/$code');

    final snapshot = await lobbyRef.get();
    if (snapshot.exists) {
      setState(() {
        _error = 'Lobby already exists';
        _loading = false;
      });
      return;
    }

    final cred = await FirebaseAuth.instance.signInAnonymously();
    final uid = cred.user!.uid;

    await lobbyRef.set({
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'map': _createSelectedMap,
    });

    LobbySession.lobbyCode = code;

    await PlayerService.createGlobalPlayerIfNotExists(uid);

    await FirebaseDatabase.instance.ref('players/$uid').update({
      'name': name,
      'colour': _selectedColor.value,
    });

    await PlayerService.joinLobby(
      name: name,
      lobbyCode: code,
      uid: uid,
      colour: _selectedColor.value,
    );
  } catch (e) {
    setState(() => _error = 'Failed to create lobby');
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}


  Widget _buildJoinCard() {
  return _buildCard(
    title: "JOIN GAME",
    child: Column(  
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Player Name'),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _lobbyController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Lobby Code'),
        ),

        const SizedBox(height: 20),

        _colorPicker(),

        const SizedBox(height: 28),

        _primaryButton("PLAY", _play),

        const SizedBox(height: 16),

        _primaryButton(
          "CREATE LOBBY",
          () {
            setState(() {
              _isCreatingLobby = true;
              _error = null;
            });
          },
          color: Colors.green,
        ),


        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
      ],
    ),
  );
}

Widget _buildCreateCard() {
  final codeController = TextEditingController(text: _createLobbyCode);

  return _buildCard(
    title: "CREATE LOBBY",
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Player Name'),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Lobby Code'),
          onChanged: (val) {
            _createLobbyCode = val.trim().toUpperCase();
          },
        ),

        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: _createSelectedMap,
          decoration: const InputDecoration(labelText: "Select Map"),
          items: const [
            DropdownMenuItem(value: 'kerala', child: Text('Kerala')),
            DropdownMenuItem(value: 'india', child: Text('India')),
            DropdownMenuItem(value: 'kerala_extended', child: Text('Kerala Extended')),
          ],
          onChanged: (value) {
            setState(() => _createSelectedMap = value!);
          },
        ),

        const SizedBox(height: 20),

        _colorPicker(),

        const SizedBox(height: 28),

        _primaryButton("CREATE", _createLobbyCustom),

        const SizedBox(height: 12),

        _primaryButton(
          "JOIN EXISTING LOBBY",
          () {
            setState(() {
              _isCreatingLobby = false;
              _error = null;
            });
          },
          color: Colors.pinkAccent,
        ),

  

        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
      ],
    ),
  );
}

Widget _buildCard({required String title, required Widget child}) {
  return Container(
    key: ValueKey(title),
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(24),
    width: 420,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.blue.shade700, width: 3),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.blue,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        child,
      ],
    ),
  );
}

Widget _colorPicker() {
  return Wrap(
    spacing: 10,
    children: playerColors.map((color) {
      final selected = color == _selectedColor;
      return GestureDetector(
        onTap: () {
          setState(() => _selectedColor = color);
        },
        child: CircleAvatar(
          radius: selected ? 20 : 18,
          backgroundColor: color,
          child: selected
              ? const Icon(Icons.check, color: Colors.white)
              : null,
        ),
      );
    }).toList(),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isCreatingLobby ? _buildCreateCard() : _buildJoinCard(),
        ),

      ),
    );
  }
}
