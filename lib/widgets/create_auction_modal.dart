import 'package:flutter/material.dart';
import '../services/market_service.dart';

class CreateAuctionModal extends StatefulWidget {
  final String lobbyCode;
  final String cityName;
  final String sellerId;
  final String sellerName;

  const CreateAuctionModal({
    super.key,
    required this.lobbyCode,
    required this.cityName,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  State<CreateAuctionModal> createState() =>
      _CreateAuctionModalState();
}

class _CreateAuctionModalState
    extends State<CreateAuctionModal> {
  final TextEditingController _priceController =
      TextEditingController(text: "100");

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Create Auction',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // City display card
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.cityName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Starting price
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Starting Price',
              prefixIcon:
                  const Icon(Icons.monetization_on),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Create button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: loading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Create Auction',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Cancel button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed:
                  loading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel', style: TextStyle(color: Colors.black),),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final price =
        int.tryParse(_priceController.text.trim());

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid price')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await MarketService.createAuction(
        lobbyCode: widget.lobbyCode,
        cityName: widget.cityName,
        sellerId: widget.sellerId,
        sellerName: widget.sellerName,
        startPrice: price,
        // ⛔ removed durationMinutes
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => loading = false);
    }
  }
}
