
import 'package:web_socket_channel/web_socket_channel.dart';

import 'common.dart';
import 'parsing.dart';
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
  parseState(decompress(response));
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
  // sendToServer(request);
}

void sendRequestUpdatePlayer() {
  sendToServer("u: $id $requestCharacterState $requestDirection");
}

void sendCommandUpdate() {
  sendToServer("update");
}

void sendRequestSpawn() {
  print("requestSpawn()");
  sendToServer('spawn');
}

void sendCommandFire() {
  if (!playerAssigned) return;
  print("sendCommandFire()");
  sendToServer("$id $commandAttack ${getMouseRotation()}");
}

void onError(dynamic value) {
  errors++;
}

void onDone() {
  dones++;
  connected = false;
}

