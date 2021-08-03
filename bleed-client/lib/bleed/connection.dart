import 'package:flutter_game_engine/bleed/send.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'parse.dart';
import 'settings.dart';
import 'state.dart';

Uri get hostURI => Uri.parse(host);

void disconnect() {
  connected = false;
  webSocketChannel.sink.close();
}

void onEvent(dynamic response) {
  framesSinceEvent = 0;
  DateTime now = DateTime.now();
  ping = now.difference(previousEvent);
  previousEvent = now;
  packagesReceived++;
  event = response;
  try {
    parseState();
  }catch(error){
    print(error);
  }
  redrawGame();
  redrawUI();
}

int attempts = 0;

void connect() {
  try {
    attempts++;
    webSocketChannel = WebSocketChannel.connect(hostURI);
    webSocketChannel.stream.listen(onEvent, onError: onError, onDone: onDone);
    attempts = 0;
    connected = true;
    respawnRequestSent = false;
    sendRequestTiles();
  } catch (error) {
    print(error);
    errors++;
    if (attempts > 10) return;
    Future.delayed(Duration(seconds: 1), connect);
  }
}

void onError(dynamic value) {
  errors++;
}

void onDone() {
  attempts = 0;
  dones++;
  connected = false;
  connect();
}
