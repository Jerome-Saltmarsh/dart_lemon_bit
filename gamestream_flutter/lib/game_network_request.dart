
import 'engine/instances.dart';

class GameNetworkRequest {
  static void sinkMessage(dynamic message) {
    gsEngine.network.sink.add(message);
  }
}