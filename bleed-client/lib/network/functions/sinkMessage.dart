import 'package:bleed_client/network/state/webSocketChannel.dart';

void sinkMessage(String message) {
  webSocketChannel.sink.add(message);
}
