
import '../services.dart';
import 'userService.dart';

class HttpSubscriptionService extends SubscriptionService {
  @override
  void init() {
    print("HttpSubscriptionService.init()");
  }

  @override
  Future<bool> isSubscribed(String playerId) async {
    final subscription = await getUserSubscriptionExpiration(playerId);
    final now = DateTime.now().toUtc();
    return subscription != null && now.isBefore(subscription);
  }
}