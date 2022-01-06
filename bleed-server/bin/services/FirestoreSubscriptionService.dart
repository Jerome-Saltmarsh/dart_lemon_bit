
import '../services.dart';

class FirestoreSubscriptionService extends SubscriptionService {
  @override
  void init() {
    print("firestoreSubscriptionService.init");
  }

  @override
  bool isSubscribed(String playerId) {
    return true;
  }
}