
import 'package:bleed_server/firestore/firestore.dart';

import '../services.dart';

class FirestoreSubscriptionService extends SubscriptionService {
  @override
  void init() {
    print("firestoreSubscriptionService.init");
    firestore.init();
  }

  @override
  Future<bool> isSubscribed(String playerId) async {
    final userDocument = await firestore.findUserById(playerId);
    return userDocument != null;
  }
}