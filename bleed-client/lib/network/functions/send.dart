import 'package:bleed_client/network/functions/sinkMessage.dart';
import 'package:bleed_client/network/state/connected.dart';

void send(String message) {
  if (!connected) return;
  sinkMessage(message);
}
