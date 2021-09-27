import 'dart:async';

import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'functions/clearState.dart';
import 'parse.dart';
import 'state.dart';

// TODO encapsulate state inside object
WebSocketChannel _webSocketChannel;
final StreamController onConnectedController = StreamController.broadcast();
final StreamController onDisconnected = StreamController.broadcast();
final StreamController onError = StreamController.broadcast();
final StreamController onConnectError = StreamController.broadcast();
final StreamController onDone = StreamController.broadcast();
final StreamController onEvent = StreamController.broadcast();
bool connected = false;
bool connecting = false;

String _connectionUri = "";

// public
void disconnect() {
  print('disconnect()');
  if (!connected) return;
  connected = false;
  connecting = false;
  if (_webSocketChannel == null) return;
  _webSocketChannel.sink.close();
  onDisconnected.add(true);
}

bool isUriConnected(String value){
  return connected && _connectionUri == value;
}

void connect(String uri) {
  print('connection.connect($uri)');
  clearState();
  connecting = true;
  _webSocketChannel = WebSocketChannel.connect(Uri.parse(uri));
  _webSocketChannel.stream.listen(_onEvent, onError: _onError, onDone: _onDone);
  _webSocketChannel.sink.add(ClientRequest.Ping.index);
  _connectionUri = uri;
}

void send(String message) {
  if (!connected) return;
  _webSocketChannel.sink.add(message);
  packagesSent++;
}

// private

void _onEvent(dynamic response) {
  if (connecting) {
    print("connection established");
    connected = true;
    connecting = false;
    onConnectedController.add(response);
    redrawUI();
    Future.delayed(Duration(seconds: 1), redrawUI);
  }

  onEvent.add(response);
  lag = framesSinceEvent;
  framesSinceEvent = 0;
  DateTime now = DateTime.now();
  ping = now.difference(previousEvent);
  previousEvent = now;
  packagesReceived++;
  // TODO doesn't belong
  event = response;
  parseState();
  redrawGame();
}

void _onError(dynamic value) {
  if (connecting) {
    print("connection connect error");
    onConnectError.add(value);
  } else {
    print("connection error");
    onError.add(value);
  }
  connected = false;
  connecting = false;
}

void _onDone() {
  print("connection done");
  _connectionUri = "";
  connected = false;
  connecting = false;
  onDone.add(true);
}
