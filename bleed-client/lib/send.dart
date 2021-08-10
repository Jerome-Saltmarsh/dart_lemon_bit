
import 'package:bleed_client/enums/ClientRequest.dart';

import 'connection.dart';
import 'enums/Weapons.dart';
import 'state.dart';


StringBuffer _buffer = StringBuffer();
const String _space = " ";
// TODO Expensive string build
String get session => '$gameId $playerId $playerUUID';

void sendRequestRevive(){
  send('${ClientRequest.Player_Revive.index} $session');
}

void sendRequestEquip(Weapon weapon) {
  send('${ClientRequest.Player_Equip.index} $session ${weapon.index}');
}

void sendRequestEquipHandgun() {
  sendRequestEquip(Weapon.HandGun);
}

void sendRequestEquipShotgun() {
  sendRequestEquip(Weapon.Shotgun);
}

void sendRequestEquipSniperRifle() {
  sendRequestEquip(Weapon.SniperRifle);
}

void sendRequestEquipMachineGun() {
  sendRequestEquip(Weapon.MachineGun);
}

void sendRequestUpdatePlayer() {
  _buffer.clear();
  _write(ClientRequest.Game_Update.index);
  _write(gameId);
  _write(playerId);
  _write(playerUUID);
  _write(requestCharacterState);
  _write(requestDirection);
  _write(requestAim.toStringAsFixed(2));
  _write(serverFrame);
  send(_buffer.toString());
}

void sendRequestSpawn() {
  print("sendRequestSpawn()");
  send('spawn');
}

void sendRequestSpawnNpc() {
  send('${ClientRequest.Spawn_Npc.index} $session');
}

void sendRequestClearNpcs() {
  send("clear-npcs");
}

void _write(dynamic value) {
  _buffer.write(value);
  _buffer.write(_space);
}

void request(ClientRequest request, String value){
  send('${request.index} $value');
}