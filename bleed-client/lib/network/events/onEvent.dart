// TODO Illegal Dependency
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/network/state/connecting.dart';
import 'package:bleed_client/network/streams/onConnected.dart';
import 'package:bleed_client/network/streams/onEvent.dart';
// TODO Illegal Dependency
import 'package:bleed_client/parse.dart';
// TODO Illegal Dependency
import 'package:bleed_client/state.dart';

void handleOnEvent(dynamic _response) {
  if (connecting) {
    print("connection established");
    connected = true;
    connecting = false;
    onConnectedController.add(_response);
  }

  streamOnEvent.add(_response);
  lag = framesSinceEvent;
  framesSinceEvent = 0;
  DateTime now = DateTime.now();
  ping = now.difference(previousEvent);
  previousEvent = now;
  // TODO doesn't belong
  event = _response;
  parseState();
  redrawCanvas();
}
