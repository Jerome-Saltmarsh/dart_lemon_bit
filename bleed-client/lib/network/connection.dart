import 'dart:async';

import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/network/state/connecting.dart';
import 'package:bleed_client/network/state/connectionUri.dart';
import 'package:bleed_client/network/state/webSocketChannel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../functions/clearState.dart';
import '../parse.dart';
import '../state.dart';

// TODO encapsulate state inside object
final StreamController onDisconnected = StreamController.broadcast();
final StreamController onError = StreamController.broadcast();
final StreamController onConnectError = StreamController.broadcast();



// public
void disconnect() {
  print('disconnect()');
  if (!connected) return;
  connected = false;
  connecting = false;
  if (webSocketChannel == null) return;
  webSocketChannel.sink.close();
  onDisconnected.add(true);
}

bool isUriConnected(String value){
  return connected && connectionUri == value;
}

void send(String message) {
  if (!connected) return;
  webSocketChannel.sink.add(message);
  packagesSent++;
}

// private


