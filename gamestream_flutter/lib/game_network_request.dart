
import 'game_network.dart';

class GameNetworkRequest {
  static void sinkMessage(dynamic message) {
    GameNetwork.sink.add(message);
  }
}