import 'package:flutter_game_engine/game_engine/game_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'common.dart';
import 'parser.dart';
import 'settings.dart';
import 'state.dart';

Uri get hostURI => Uri.parse(host);

void disconnect() {
  connected = false;
  webSocketChannel.sink.close();
}

void sendToServer(String message) {
  if (!connected) return;
  webSocketChannel.sink.add(message);
  packagesSent++;
}

void onEvent(dynamic response) {
  framesSinceEvent = 0;
  DateTime now = DateTime.now();
  ping = now.difference(previousEvent);
  previousEvent = now;
  packagesReceived++;
  event = response;
  parseState();
  redrawGame();
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
  } catch (error) {
    errors++;
    if (attempts > 10) return;
    Future.delayed(Duration(seconds: 1), connect);
  }
}

void sendCommandEquipHandGun() {
  sendCommandEquip(weaponHandgun);
}

void sendCommandEquipShotgun() {
  sendCommandEquip(weaponShotgun);
}

void sendCommandEquip(int weapon) {
  Map<String, dynamic> request = Map();
  request[keyCommand] = commandEquip;
  request[keyEquipValue] = weapon;
  request[keyId] = playerId;
}

StringBuffer _buffer = StringBuffer();

void _write(dynamic value) {
  _buffer.write(value);
  _buffer.write(" ");
}

void sendRequestUpdatePlayer() {
  _buffer.clear();
  _write("u:");
  _write(playerId);
  _write(playerUUID);
  _write(requestCharacterState);
  _write(requestDirection);
  _write(requestAim);
  sendToServer(_buffer.toString());
}

void sendCommandUpdate() {
  sendToServer("update");
}

void sendRequestSpawn() {
  sendToServer('spawn');
}

void sendRequestSpawnNpc() {
  sendToServer('spawn-npc');
}

void sendRequestClearNpcs() {
  sendToServer("clear-npcs");
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
