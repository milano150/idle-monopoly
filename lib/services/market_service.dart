import 'package:firebase_database/firebase_database.dart';

class MarketService {
  static final DatabaseReference _db =
      FirebaseDatabase.instance.ref();

  static Future<void> createAuction({
    required String lobbyCode,
    required String cityName,
    required String sellerId,
    required String sellerName,
    required int startPrice,
  }) async {
    final lobbyRef = _db.child('lobbies/$lobbyCode');
    final cityRef = lobbyRef.child('cities/$cityName');
    final marketRef = lobbyRef.child('market').push();


    // --- SAFETY CHECK ---
    final citySnap = await cityRef.get();
    if (!citySnap.exists) {
      throw Exception('City does not exist');
    }

    final cityData =
        Map<String, dynamic>.from(citySnap.value as Map);

    if (cityData['owner'] != sellerId) {
      throw Exception('You do not own this city');
    }

    if (cityData['inMarket'] == true) {
      throw Exception('City already in auction');
    }

    // --- LOCK CITY ---
    await cityRef.update({
      'inMarket': true,
    });

    final now = DateTime.now().millisecondsSinceEpoch;

    // --- CREATE AUCTION ---
    await marketRef.set({
      'type': 'public',
      'city': cityName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'startPrice': startPrice,
      'currentBid': startPrice,
      'highestBidderId': null,
      'highestBidderName': null,
      'createdAt': now,
      'lastBidAt': now, // ✅ FIXED

    });

    await lobbyRef.child('cities/$cityName').update({
      'inMarket': true,
    });
  }
}
