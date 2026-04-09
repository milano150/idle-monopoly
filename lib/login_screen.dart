import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'services/player_service.dart';

class LobbySession {
  static String lobbyCode = '';
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _creating = false;

  String _map = "kerala";

  final List<String> _maps = [
    "kerala",
    "india",
    "kerala_extended",
  ];

  // ================= PLAY =================
  Future<void> _play() async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim().toUpperCase();

    if (name.isEmpty || code.isEmpty) {
      setState(() => _error = "Enter name & code");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final lobbyRef =
          FirebaseDatabase.instance.ref('lobbies/$code');
      final snap = await lobbyRef.get();

      if (!snap.exists) {
        setState(() {
          _error = "Lobby not found";
          _loading = false;
        });
        return;
      }

      LobbySession.lobbyCode = code;

      final cred = await FirebaseAuth.instance.signInAnonymously();
      final uid = cred.user!.uid;

      await PlayerService.createGlobalPlayerIfNotExists(uid);

      await FirebaseDatabase.instance.ref('players/$uid').update({
        'name': name,
        'colour': Colors.blue.value,
      });

      await PlayerService.joinLobby(
        name: name,
        lobbyCode: code,
        uid: uid,
        colour: Colors.blue.value,
      );
    } catch (e) {
      setState(() => _error = "Something went wrong");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= CREATE =================
  Future<void> _create() async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim().toUpperCase();

    if (name.isEmpty || code.isEmpty) {
      setState(() => _error = "Enter name & code");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ref = FirebaseDatabase.instance.ref('lobbies/$code');

      if ((await ref.get()).exists) {
        setState(() {
          _error = "Lobby exists";
          _loading = false;
        });
        return;
      }

      final cred = await FirebaseAuth.instance.signInAnonymously();
      final uid = cred.user!.uid;

      await ref.set({
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'map': _map,
      });

      LobbySession.lobbyCode = code;

      await PlayerService.createGlobalPlayerIfNotExists(uid);

      await FirebaseDatabase.instance.ref('players/$uid').update({
        'name': name,
        'colour': Colors.blue.value,
      });

      await PlayerService.joinLobby(
        name: name,
        lobbyCode: code,
        uid: uid,
        colour: Colors.blue.value,
      );
    } catch (e) {
      setState(() => _error = "Failed to create");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= INPUT =================
  Widget _input(String hint, TextEditingController c) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          )
        ],
      ),
      child: TextField(
        controller: c,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= BUTTON =================
  Widget _bigButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: _loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 280,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.6),
              blurRadius: 25,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Center(
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _secondaryButton(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  // ================= MAP SELECTOR =================
  Widget _mapSelector() {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _map,
          dropdownColor: const Color(0xFF0F172A),
          style: const TextStyle(color: Colors.white),
          isExpanded: true,
          items: _maps.map((map) {
            return DropdownMenuItem(
              value: map,
              child: Text(
                map.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _map = value!);
          },
        ),
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF020617),
            ],
            radius: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            const Text(
              "urban.idle",
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 60),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey(_creating),
                children: [
                  _input("PLAYER NAME", _nameController),
                  const SizedBox(height: 18),

                  _input("LOBBY CODE", _codeController),

                  if (_creating) ...[
                    const SizedBox(height: 18),
                    _mapSelector(),
                  ],

                  const SizedBox(height: 30),

                  _bigButton(
                    _creating ? "CREATE GAME" : "PLAY",
                    _creating ? _create : _play,
                  ),

                  const SizedBox(height: 14),

                  _secondaryButton(
                    _creating ? "JOIN INSTEAD" : "CREATE GAME",
                    () => setState(() => _creating = !_creating),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}