
import 'services/DummySubscriptionService.dart';

final _Services services = _Services();

class _Services {
  final subscription = DummySubscriptionService();
}

abstract class SubscriptionService {
  bool isSubscribed(String playerId);
}