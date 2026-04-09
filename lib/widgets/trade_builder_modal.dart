import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TradeBuilderModal extends StatefulWidget {
  final String lobbyCode;
  final String currentPlayerId;
  final String currentPlayerName;

  const TradeBuilderModal({
    super.key,
    required this.lobbyCode,
    required this.currentPlayerId,
    required this.currentPlayerName,
  });

  @override
  State<TradeBuilderModal> createState() =>
      _TradeBuilderModalState();
}

class _TradeBuilderModalState
    extends State<TradeBuilderModal> {
  final db = FirebaseDatabase.instance.ref();

  Color getStateColor(String state) {
    switch (state) {
      case "Maharashtra":
        return Colors.orange;
      case "Delhi":
        return Colors.blue;
      case "Karnataka":
        return Colors.green;
      case "Tamil Nadu":
        return Colors.red;
      case "Kerala":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }


  String? targetId;
  String? targetName;

  List<String> myProperties = [];
  List<String> theirProperties = [];

  List<String> selectedMyProperties = [];
  List<String> selectedTheirProperties = [];

  final myCoinsController =
      TextEditingController(text: "0");
  final theirCoinsController =
      TextEditingController(text: "0");

  @override
  void initState() {
    super.initState();
    _loadMyProperties();
  }

  Future<void> _loadMyProperties() async {
    final snap = await db
        .child(
            'lobbies/${widget.lobbyCode}/cities')
        .get();

    if (!snap.exists) return;

    final data =
        Map<String, dynamic>.from(
            snap.value as Map);

    final temp = <String>[];

    data.forEach((city, value) {
      if (value['owner'] ==
          widget.currentPlayerId) {
        temp.add(city);
      }
    });

    setState(() {
      myProperties = temp;
    });
  }

  Future<void> _loadTheirProperties() async {
    if (targetId == null) return;

    final snap = await db
        .child(
            'lobbies/${widget.lobbyCode}/cities')
        .get();

    if (!snap.exists) return;

    final data =
        Map<String, dynamic>.from(
            snap.value as Map);

    final temp = <String>[];

    data.forEach((city, value) {
      if (value['owner'] == targetId) {
        temp.add(city);
      }
    });

    setState(() {
      theirProperties = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
                    top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            children: [
              const Center(
                child: Text(
                  "Create Trade",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildPlayerSelector(),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: _buildPropertyColumn(
                    title: "You Give",
                    properties: myProperties,
                    selected:
                        selectedMyProperties,
                    onTap: (city) {
                      setState(() {
                        selectedMyProperties
                                .contains(city)
                            ? selectedMyProperties
                                .remove(city)
                            : selectedMyProperties
                                .add(city);
                      });
                    },
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildPropertyColumn(
                    title: "They Give",
                    properties:
                        theirProperties,
                    selected:
                        selectedTheirProperties,
                    onTap: (city) {
                      setState(() {
                        selectedTheirProperties
                                .contains(city)
                            ? selectedTheirProperties
                                .remove(city)
                            : selectedTheirProperties
                                .add(city);
                      });
                    },
                  )),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          myCoinsController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        labelText:
                            "You Give Coins",
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller:
                          theirCoinsController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        labelText:
                            "They Give Coins",
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.indigo,
                  ),
                  onPressed:
                      _submitTrade,
                  child: const Text(
                    "Send Trade",
                    style: TextStyle(
                        fontWeight:
                            FontWeight.w600, color: Colors.white),
                        
                        
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerSelector() {
    return FutureBuilder(
      future: db
          .child(
              'lobbies/${widget.lobbyCode}/players')
          .get(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox();
        }

        final players =
            Map<String, dynamic>.from(
                snap.data!.value as Map);

        return DropdownButtonFormField<String>(
          decoration:
              const InputDecoration(
            labelText: "Select Player",
            border:
                OutlineInputBorder(),
          ),
          value: targetId,
          items: players.entries
              .where((e) =>
                  e.key !=
                  widget.currentPlayerId)
              .map((e) {
            return DropdownMenuItem(
              value: e.key,
              child: Text(e.value['name']),
            );
          }).toList(),
          onChanged: (v) async {
            setState(() {
              targetId = v;
              targetName =
                  players[v]['name'];
            });
            await _loadTheirProperties();
          },
        );
      },
    );
  }

  Widget _buildPropertyColumn({
    required String title,
    required List<String> properties,
    required List<String> selected,
    required Function(String) onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),

      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight:
                    FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...properties.map((city) {
            final isSelected =
                selected.contains(city);
            return GestureDetector(
              onTap: () => onTap(city),
              child: Container(
                margin:
                    const EdgeInsets.symmetric(
                        vertical: 4),
                padding:
                    const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                  ? Colors.indigo.withOpacity(0.15)
                  : Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                          8),
                ),
                child: Text(city),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _submitTrade() async {
    if (targetId == null) return;

    final myCoins =
        int.tryParse(
                myCoinsController.text) ??
            0;
    final theirCoins =
        int.tryParse(
                theirCoinsController
                    .text) ??
            0;

    await db
        .child(
            'lobbies/${widget.lobbyCode}/trades')
        .push()
        .set({
      'type': 'private',
      'status': 'pending',
      'playerA': {
        'id': widget.currentPlayerId,
        'name':
            widget.currentPlayerName,
        'coins': myCoins,
        'properties':
            selectedMyProperties,
      },
      'playerB': {
        'id': targetId,
        'name': targetName,
        'coins': theirCoins,
        'properties':
            selectedTheirProperties,
      }
    });

    Navigator.pop(context);
  }
}
