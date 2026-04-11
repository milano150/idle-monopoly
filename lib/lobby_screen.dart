import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'services/player_service.dart';
import 'main.dart';
import 'lobby_session.dart';

class LobbyScreen extends StatefulWidget {
  final String uid;
  final String username;

  const LobbyScreen({
    super.key,
    required this.uid,
    required this.username,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController _code = TextEditingController();

  bool _loading = false;
  String? _error;

  List<String> recentLobbies = [];

  @override
  void initState() {
    super.initState();
    _loadRecentLobbies();
  }

  Future<void> _loadRecentLobbies() async {
    final ref = FirebaseDatabase.instance
        .ref('users/${widget.uid}/recentLobbies');

    final snap = await ref.get();

    if (!snap.exists) return;

    final data = Map<String, dynamic>.from(snap.value as Map);

    setState(() {
      recentLobbies = data.keys.toList().reversed.toList();
    });
  }

  // ================= JOIN =================
  Future<void> _join([String? codeOverride]) async {
    final code = (codeOverride ?? _code.text).trim().toUpperCase();

    if (code.isEmpty) {
      setState(() => _error = "Enter lobby code");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ref = FirebaseDatabase.instance.ref('lobbies/$code');
      final snap = await ref.get();

      if (!snap.exists) {
        setState(() {
          _error = "Lobby not found";
          _loading = false;
        });
        return;
      }

      await PlayerService.joinLobby(
        name: widget.username,
        lobbyCode: code,
        uid: widget.uid,
        colour: Colors.blue.value,
      );

      // 🔥 SAVE TO RECENTS
      await FirebaseDatabase.instance
          .ref('users/${widget.uid}/recentLobbies/$code')
          .set(true);

      LobbySession.lobbyCode = code;

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScaffold(playerId: widget.uid),
        ),
      );
    } catch (e) {
      setState(() => _error = "Join failed");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= CREATE =================
  Future<void> _create() async {
    final code = _code.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() => _error = "Enter lobby code");
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
          _error = "Lobby already exists";
          _loading = false;
        });
        return;
      }

      await ref.set({
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      await PlayerService.joinLobby(
        name: widget.username,
        lobbyCode: code,
        uid: widget.uid,
        colour: Colors.blue.value,
      );

      // 🔥 SAVE TO RECENTS
      await FirebaseDatabase.instance
          .ref('users/${widget.uid}/recentLobbies/$code')
          .set(true);

      LobbySession.lobbyCode = code;

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScaffold(playerId: widget.uid),
        ),
      );
    } catch (e) {
      setState(() => _error = "Create failed");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= UI =================

  Widget _input() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          )
        ],
      ),
      child: TextField(
        controller: _code,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "LOBBY CODE",
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _button(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: _loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 260,
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.5),
              blurRadius: 20,
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _recentList() {
    if (recentLobbies.isEmpty) return const SizedBox();

    return Column(
      children: [
        const SizedBox(height: 30),
        const Text(
          "RECENT LOBBIES",
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 10),

        ...recentLobbies.map((code) {
          return GestureDetector(
            onTap: () => _join(code),
            child: Container(
              width: 260,
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  code,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [

              const Text(
                "join a lobby.",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              _input(),

              const SizedBox(height: 20),

              _button("JOIN", () => _join()),
              _button("CREATE", _create),

              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],

              _recentList(),
            ],
          ),
        ),
      ),
    );
  }
}