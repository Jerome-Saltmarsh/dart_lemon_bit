
import 'state.dart';


StringBuffer _buffer = StringBuffer();

void sendRequestTiles(){
  sendToServer('get-tiles');
}

void sendTogglePass1(){
  sendToServer('toggle-pass-1');
}

void sendTogglePass2(){
  sendToServer('toggle-pass-2');
}

void sendTogglePass3(){
  sendToServer('toggle-pass-3');
}

void sendTogglePass4(){
  sendToServer('toggle-pass-4');
}

void sendRequestRevive(){
  print('sendRequestRevive()');
  sendToServer('revive: $playerId $playerUUID');
}

void sendCommandEquipHandGun() {
  sendToServer('equip handgun: $playerId $playerUUID');
}

void sendCommandEquipShotgun() {
  sendToServer('equip shotgun: $playerId $playerUUID');
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

void _write(dynamic value) {
  _buffer.write(value);
  _buffer.write(" ");
}

void sendToServer(String message) {
  if (!connected) return;
  webSocketChannel.sink.add(message);
  packagesSent++;
}