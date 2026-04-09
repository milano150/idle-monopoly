import 'package:firebase_database/firebase_database.dart';

class LogService {
  static final _db = FirebaseDatabase.instance.ref();

  static Future<void> add({
    required String lobbyCode,
    required String text,
  }) async {
    await _db
        .child('lobbies/$lobbyCode/logs')
        .push()
        .set({
      'text': text,
      'timestamp': ServerValue.timestamp,
    });
  }
}
