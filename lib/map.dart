import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class KeralaMapScreen extends StatefulWidget {
  final String playerId;
  const KeralaMapScreen({super.key, required this.playerId});

  @override
  State<KeralaMapScreen> createState() => _KeralaMapScreenState();
}

class _KeralaMapScreenState extends State<KeralaMapScreen> {
  final DatabaseReference db = FirebaseDatabase.instance.ref();
  Map<String, String> owners = {}; // districtName -> owner
  String svgData = '';
  StreamSubscription<DatabaseEvent>? _citiesSubscription;
  int _coins = 0;
  StreamSubscription<DatabaseEvent>? _coinsSubscription;

  @override
  void initState() {
    super.initState();
    _loadSvg();
    _listenToOwners();
    _listenToCoins();
  }

  @override
  void dispose() {
    _citiesSubscription?.cancel();
    _coinsSubscription?.cancel();
    super.dispose();
  }

  // Load SVG from assets
  void _loadSvg() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('assets/kerala_map.svg');
    setState(() => svgData = data);
  }

  // Listen to real-time Firebase updates for city ownership
  void _listenToOwners() {
    _citiesSubscription = db.child('cities').onValue.listen((event) {
      final data = event.snapshot.value as Map? ?? {};
      setState(() {
        owners = data.map((key, value) => MapEntry(key, value['owner'] ?? ''));
      });
    });
  }

  // Listen to coins of player
  void _listenToCoins() {
    _coinsSubscription =
        db.child('players/${widget.playerId}/coins').onValue.listen((event) {
      final newCoins = event.snapshot.value;
      if (newCoins != null) {
        setState(() {
          _coins = int.tryParse(newCoins.toString()) ?? 0;
        });
      }
    });
  }

  // Color each district dynamically
  String _colorizeSvg(String rawSvg) {
    String coloredSvg = rawSvg;

    owners.forEach((district, owner) {
      String color;
      if (owner == widget.playerId) {
        color = '#00FF00'; // green for self
      } else if (owner.isNotEmpty) {
        color = '#FF0000'; // red for others
      } else {
        color = '#CCCCCC'; // gray if unowned
      }

      // Handle paths with existing fill attribute
      final fillRegex = RegExp(
          r'id="' + RegExp.escape(district) + r'"([^>]*)fill="[^"]*"',
          caseSensitive: false);
      if (fillRegex.hasMatch(coloredSvg)) {
        coloredSvg = coloredSvg.replaceAllMapped(fillRegex, (match) {
          String rest = match[1] ?? '';
          return 'id="$district"$rest fill="$color"';
        });
        return;
      }

      // Handle paths with style="fill:..."
      final styleRegex = RegExp(
          r'id="' + RegExp.escape(district) + r'"([^>]*)style="[^"]*fill:[^;"]*;?[^"]*"',
          caseSensitive: false);
      if (styleRegex.hasMatch(coloredSvg)) {
        coloredSvg = coloredSvg.replaceAllMapped(styleRegex, (match) {
          String rest = match[1] ?? '';
          return 'id="$district"$rest style="fill:$color;"';
        });
        return;
      }

      // If no fill or style exists, add fill
      final noFillRegex = RegExp(r'id="' + RegExp.escape(district) + r'"([^>]*)>');
      coloredSvg = coloredSvg.replaceAllMapped(noFillRegex, (match) {
        String rest = match[1] ?? '';
        return 'id="$district"$rest fill="$color">';
      });
    });

    return coloredSvg;
  }

  @override
  Widget build(BuildContext context) {
    if (svgData.isEmpty) return const Center(child: CircularProgressIndicator());

    final coloredSvg = _colorizeSvg(svgData);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ---- Top Coins Bar ----
          Container(
            height: 70,
            width: double.infinity,
            color: Colors.indigo,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                '$_coins 🪙',
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // ---- Main Map ----
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 5.0,
              child: SvgPicture.string(
                coloredSvg,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
