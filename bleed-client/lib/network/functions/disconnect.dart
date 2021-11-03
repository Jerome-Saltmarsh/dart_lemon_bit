import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/network/state/connecting.dart';
import 'package:bleed_client/network/state/webSocketChannel.dart';
import 'package:bleed_client/network/streams/onDisconnected.dart';

void disconnect() {
  print('disconnect()');
  if (!connected) return;
  connected = false;
  connecting = false;
  if (webSocketChannel == null) return;
  webSocketChannel.sink.close();
  onDisconnected.add(true);
}
