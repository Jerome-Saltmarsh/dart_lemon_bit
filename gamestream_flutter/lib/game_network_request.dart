
import 'engine/instances.dart';

class GameNetworkRequest {
  static void sinkMessage(dynamic message) {
    gamestream.network.sink.add(message);
  }
}