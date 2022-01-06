

import '../services.dart';

class DummySubscriptionService extends SubscriptionService {
  @override
  Future<bool> isSubscribed(String playerId) {
    return Future.value(true);
  }

  @override
  void init() {
    print("dummySubscriptionService.init()");
    // nothing to do
  }
}