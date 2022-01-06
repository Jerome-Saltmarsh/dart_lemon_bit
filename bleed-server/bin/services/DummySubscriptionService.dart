

import '../services.dart';

class DummySubscriptionService extends SubscriptionService {
  @override
  bool isSubscribed(String playerId) {
    return false;
  }
}