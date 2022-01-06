

import '../services.dart';

class DummySubscriptionService extends SubscriptionService {
  @override
  bool isSubscribed(String playerId) {
    return true;
  }

  @override
  void init() {
    print("dummySubscriptionService.init()");
    // nothing to do
  }
}