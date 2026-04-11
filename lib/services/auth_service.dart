import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ================= ANONYMOUS (keep this if you want guests)
  static Future<String> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    return cred.user!.uid;
  }

  // ================= REGISTER
  static Future<String?> register(String username, String password) async {
    final usersRef = _db.child('users');

    final snap = await usersRef.get();

    if (snap.exists) {
      final data = Map<String, dynamic>.from(snap.value as Map);

      for (final entry in data.entries) {
        if (entry.value['username'] == username) {
          return "Username already exists";
        }
      }
    }

    final cred = await _auth.signInAnonymously();
    final uid = cred.user!.uid;

    await usersRef.child(uid).set({
      'username': username,
      'password': password,
    });

    return uid;
  }

  // ================= LOGIN
  static Future<String?> login(String username, String password) async {
    final usersRef = _db.child('users');
    final snap = await usersRef.get();

    if (!snap.exists) return "No users";

    final data = Map<String, dynamic>.from(snap.value as Map);

    for (final entry in data.entries) {
      final user = Map<String, dynamic>.from(entry.value);

      if (user['username'] == username &&
          user['password'] == password) {
        
        // sign in (new session)
        final cred = await _auth.signInAnonymously();

        return entry.key; // return ORIGINAL UID
      }
    }

    return "Invalid credentials";
  }
}