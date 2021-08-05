
import 'package:flutter_game_engine/bleed/enums.dart';
import 'package:flutter_game_engine/bleed/utils.dart';

import 'connection.dart';
import 'state.dart';


StringBuffer _buffer = StringBuffer();

void requestThrowGrenade(){
  if (!playerAssigned) return;
  send('grenade $playerId $playerUUID');
}

void sendRequestTiles(){
  print('sendRequestTiles()');
  send('get-tiles');
}

void sendRequestRevive(){
  print('sendRequestRevive()');
  send('revive: $playerId $playerUUID');
}

void sendRequestEquip(Weapon weapon) {
  send('equip $playerId $playerUUID ${weapon.index}');
}

void sendRequestEquipHandgun() {
  sendRequestEquip(Weapon.HandGun);
}

void sendRequestEquipShotgun() {
  sendRequestEquip(Weapon.Shotgun);
}

void sendRequestUpdatePlayer() {
  _buffer.clear();
  _write("u:");
  _write(playerId);
  _write(playerUUID);
  _write(requestCharacterState);
  _write(requestDirection);
  _write(requestAim.toStringAsFixed(1));
  _write(serverFrame);
  send(_buffer.toString());
}

void sendCommandUpdate() {
  send("update");
}

void sendRequestSpawn() {
  print("sendRequestSpawn()");
  send('spawn');
}

void sendRequestSpawnNpc() {
  send('spawn-npc');
}

void sendRequestClearNpcs() {
  send("clear-npcs");
}

void _write(dynamic value) {
  _buffer.write(value);
  _buffer.write(" ");
}

