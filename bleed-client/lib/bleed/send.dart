
import 'connection.dart';
import 'enums/Weapons.dart';
import 'state.dart';


StringBuffer _buffer = StringBuffer();

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

void sendRequestEquipSniperRifle() {
  sendRequestEquip(Weapon.SniperRifle);
}

void sendRequestUpdatePlayer() {
  _buffer.clear();
  _write("u:");
  _write(playerId);
  _write(playerUUID);
  _write(requestCharacterState);
  _write(requestDirection);
  _write(requestAim.toStringAsFixed(2));
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

