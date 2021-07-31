
import 'package:flutter_game_engine/game_engine/game_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'common.dart';
import 'parser.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

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


void connect() {
  try {
    webSocketChannel = WebSocketChannel.connect(hostURI);
    webSocketChannel.stream.listen(onEvent, onError: onError, onDone: onDone);
    connected = true;
  } catch (error) {
    errors++;
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
  // sendToServer(request);
}

void sendRequestUpdatePlayer() {
  sendToServer("u: $playerId $requestCharacterState $requestDirection $requestAim");
}

void sendRequestFire(){
  sendToServer("fire: $playerId $requestAim");
}

void sendCommandUpdate() {
  sendToServer("update");
}

void sendRequestSpawn() {
  sendToServer('spawn');
}

void sendRequestSpawnNpc(){
  sendToServer('spawn-npc');
}

void sendRequestClearNpcs(){
  sendToServer("clear-npcs");
}

void onError(dynamic value) {
  errors++;
}

void onDone() {
  dones++;
  connected = false;
}

