import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/network/streams/eventStream.dart';
import 'package:bleed_client/network/streams/onConnected.dart';

void handleOnEvent(dynamic _response) {
  if (connecting) {
    connection.value = Connection.Connected;
    onConnectedController.add(_response);
  }
  eventStream.add(_response);
}
