import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/network/state/connecting.dart';
import 'package:bleed_client/network/streams/onConnected.dart';
import 'package:bleed_client/network/streams/onEvent.dart';

void handleOnEvent(dynamic _response) {
  if (connecting) {
    connecting = false;
    connected = true;
    onConnectedController.add(_response);
  }
  streamOnEvent.add(_response);
}
