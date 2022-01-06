
import 'package:bleed_server/system.dart';

import 'services/DummySubscriptionService.dart';
import 'services/FirestoreSubscriptionService.dart';

final _Services services = _Services();

class _Services {
  final subscription = isLocalMachine
      ? DummySubscriptionService()
      : FirestoreSubscriptionService();
}

abstract class SubscriptionService {
  Future<bool> isSubscribed(String playerId);
  void init();
}