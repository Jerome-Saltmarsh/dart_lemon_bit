
import 'package:bleed_server/user-service-client/userServiceHttpClient.dart';

import '../services.dart';

class HttpSubscriptionService extends SubscriptionService {

  @override
  void init() {
    print("HttpSubscriptionService.init()");
  }

  @override
  Future<bool> isSubscribed(String playerId) async {
    final account = await userService.getAccount(playerId);
    if (account == null) return false;
    return account.subscriptionActive;
  }
}