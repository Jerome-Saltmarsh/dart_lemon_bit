import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/network/state/webSocketChannel.dart';
// TODO Illegal Import
import 'package:bleed_client/state.dart';

void send(String message) {
  if (!connected) return;
  webSocketChannel.sink.add(message);
  packagesSent++;
}
