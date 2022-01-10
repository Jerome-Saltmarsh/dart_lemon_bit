
import 'services/HttpSubscriptionService.dart';

final _Services services = _Services();

class _Services {
  final subscription = HttpSubscriptionService();
}

abstract class SubscriptionService {
  Future<bool> isSubscribed(String playerId);
  void init();
}