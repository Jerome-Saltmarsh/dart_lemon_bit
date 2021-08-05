import 'dart:async';

import 'package:flutter_game_engine/game_engine/game_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'parse.dart';
import 'state.dart';

// state
WebSocketChannel _webSocketChannel;
bool connected = false;
bool connecting = false;
final StreamController onConnected = StreamController();
final StreamController onDisconnected = StreamController();
final StreamController onError = StreamController();
final StreamController onConnectError = StreamController();
final StreamController onDone = StreamController();
final StreamController onEvent = StreamController();

// public

void disconnect() {
  print('disconnect()');
  connected = false;
  connecting = false;
  if (_webSocketChannel == null) return;
  _webSocketChannel.sink.close();
}

void connectLocalHost({int port = 8080}) {
  connect('ws://localhost:$port');
}

void connect(String uri) {
  print('connection.connect($uri)');
    connecting = true;
    _webSocketChannel = WebSocketChannel.connect(Uri.parse(uri));
    _webSocketChannel.stream
        .listen(_onEvent, onError: _onError, onDone: _onDone);
  _webSocketChannel.sink.add('get-tiles');
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
    onConnected.add(response);
  }

  onEvent.add(response);
  framesSinceEvent = 0;
  DateTime now = DateTime.now();
  ping = now.difference(previousEvent);
  previousEvent = now;
  packagesReceived++;
  event = response;
  try {
    parseState();
  } catch (error) {
    print(error);
  }
  redrawGame();
  redrawUI();
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
  connected = false;
  connecting = false;
  onDone.add(true);
}
