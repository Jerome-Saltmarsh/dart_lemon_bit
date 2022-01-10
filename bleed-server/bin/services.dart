
import 'package:bleed_server/system.dart';

import 'services/DummySubscriptionService.dart';
import 'services/FirestoreSubscriptionService.dart';
import 'services/HttpSubscriptionService.dart';

final _Services services = _Services();

class _Services {
  // final subscription = isLocalMachine
  //     ? DummySubscriptionService()
  //     : FirestoreSubscriptionService();
  final subscription = HttpSubscriptionService();
}

abstract class SubscriptionService {
  Future<bool> isSubscribed(String playerId);
  void init();
}