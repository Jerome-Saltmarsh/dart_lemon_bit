import 'package:flutter_game_engine/bleed/send.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'parse.dart';
import 'state.dart';


// state
WebSocketChannel _webSocketChannel;
bool connected = false;
bool connecting = false;

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
  try {
    connecting = true;
    _webSocketChannel = WebSocketChannel.connect(Uri.parse(uri));
    _webSocketChannel.stream
        .listen(_onEvent, onError: _onError, onDone: _onDone);
    connected = true;
    connecting = false;
    sendRequestTiles();
    print("connection established");
  } catch (error) {
    print("connection failed");
    print(error);
    errors++;
    connected = false;
    connecting = false;
  }
}

void send(String message) {
  if (!connected) return;
  _webSocketChannel.sink.add(message);
  packagesSent++;
}

// private

void _onEvent(dynamic response) {
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
  print("connection error");
  errors++;
  connected = false;
  connecting = false;
}

void _onDone() {
  print("connection done");
  connected = false;
  connecting = false;
}
