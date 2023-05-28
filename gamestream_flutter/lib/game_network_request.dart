
import 'package:gamestream_flutter/instances/gamestream.dart';

class GameNetworkRequest {
  static void sinkMessage(dynamic message) {
    gamestream.network.sink.add(message);
  }
}