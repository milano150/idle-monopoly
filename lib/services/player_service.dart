import 'package:firebase_database/firebase_database.dart';

class PlayerService {
  static final _db = FirebaseDatabase.instance.ref();

  // Global profile
  static Future<void> createGlobalPlayerIfNotExists(String uid) async {
    final ref = _db.child('players/$uid');
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'name': 'Player',
        'colour': 0xFF2F00FF,
        'createdAt': ServerValue.timestamp,
      });
    }
  }

  // Join EXISTING lobby with name + colour
  static Future<void> joinLobby({
    required String lobbyCode,
    required String uid,
    required String name,
    required int colour,
  }) async {
    final lobbyPlayerRef =
        _db.child('lobbies/$lobbyCode/players/$uid');

    final snap = await lobbyPlayerRef.get();

    if (!snap.exists) {
      await lobbyPlayerRef.set({
        'name': name,
        'colour': colour,
        'coins': 5000,
        'joinedAt': ServerValue.timestamp,
      });
    }
  }
}
