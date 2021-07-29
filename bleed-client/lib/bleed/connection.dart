
import 'package:flutter_game_engine/game_engine/game_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'common.dart';
import 'parsing.dart';
import 'keys.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

void requestSpawn(String playerName) {
  print("request spawn");
  Map<String, dynamic> request = Map();
  request[keyCommand] = commandSpawn;
  request[keyPlayerName] = playerName;
  sendToServer(request);
}

void sendCommandFire() {
  if (!playerAssigned) return;
  print("send command fire");
  Map<String, dynamic> request = Map();
  request[keyCommand] = commandAttack;
  request[keyId] = id;
  request[keyRotation] = getMouseRotation();
  sendToServer(request);
}

void sendCommand(int value) {
  if (!connected) return;
  Map<String, dynamic> request = Map();
  request[keyCommand] = value;
  sendToServer(request);
}

void disconnect() {
  connected = false;
  webSocketChannel.sink.close();
}


void sendToServer(dynamic event) {
  if (!connected) return;
  webSocketChannel.sink.add(encode(event));
  packagesSent++;
}


void onEvent(dynamic valueString) {
  framesSinceEvent = 0;
  DateTime now = DateTime.now();
  ping = now.difference(previousEvent);
  previousEvent = now;
  packagesReceived++;
  event = valueString;
  parseState(decompress(valueString));
  //
  // if (valueObject[keyNpcs] != null) {
  //   npcs = unparseNpcs(valueObject[keyNpcs]);
  // }
  // if (valueObject[keyPlayers] != null) {
  //   players = unparsePlayers(valueObject[keyPlayers]);
  // }
  // if (id < 0 && valueObject[keyId] != null) {
  //   id = valueObject[keyId];
  //   cameraX = playerCharacter[posX] - (size.width * 0.5);
  //   cameraY = playerCharacter[posY] - (size.height * 0.5);
  // }
  // // Play bullet audio
  // if (valueObject[keyBullets] != null) {
  //   bullets = unparseBullets(valueObject[keyBullets]);
  // }
  // forceRedraw();
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
  request[keyId] = id;
  sendToServer(request);
}

void sendCommandUpdate() {
  Map<String, dynamic> request = Map();
  request[keyCommand] = commandUpdate;
  if (playerAssigned) {
    request['s'] = requestCharacterState;
    request[keyId] = id;
    if (requestCharacterState == characterStateAiming && mouseAvailable) {
      request[keyAimAngle] = getMouseRotation();
    }else{
      request['d'] = requestDirection;
    }
  }
  sendToServer(request);
}

void onError(dynamic value) {
  errors++;
}

void onDone() {
  dones++;
  connected = false;
}

Uri get hostURI => Uri.parse(host);