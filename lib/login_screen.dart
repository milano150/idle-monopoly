import 'package:flutter/material.dart';
import 'lobby_screen.dart';
import 'services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _pass = TextEditingController();

  bool _loading = false;
  bool _register = false;
  bool _obscure = true;
  String? _error;

  Future<void> _submit() async {
    final username = _name.text.trim();
    final password = _pass.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = "Fill all fields");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      String? uid;

      if (_register) {
        uid = await AuthService.register(username, password);
      } else {
        uid = await AuthService.login(username, password);
      }

      if (uid == null ||
          uid.contains("Invalid") ||
          uid.contains("exists")) {
        setState(() {
          _error = uid ?? "Auth failed";
          _loading = false;
        });
        return;
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LobbyScreen(
            uid: uid!,
            username: username,
          ),
        ),
      );
    } catch (e) {
      setState(() => _error = "Something went wrong");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= INPUT =================
  Widget _input(
    String hint,
    TextEditingController c, {
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(vertical: 6),
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
        controller: c,
        obscureText: obscure,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= BUTTON =================
  Widget _mainButton(String text) {
    return GestureDetector(
      onTap: _loading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 280,
        height: 55,
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _switchButton() {
    return TextButton(
      onPressed: () => setState(() => _register = !_register),
      child: Text(
        _register ? "Already have an account? Login"
                  : "Create new account",
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "urban.idle",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 50),

            _input("USERNAME", _name),

            _input(
              "      PASSWORD",
              _pass,
              obscure: _obscure,
              suffix: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white54,
                ),
                onPressed: () {
                  setState(() => _obscure = !_obscure);
                },
              ),
            ),

            const SizedBox(height: 25),

            _mainButton(_register ? "REGISTER" : "LOGIN"),

            const SizedBox(height: 10),

            _switchButton(),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }
}