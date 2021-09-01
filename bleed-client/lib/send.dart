
import 'package:bleed_client/common.dart';
import 'package:bleed_client/enums/ClientRequest.dart';

import 'connection.dart';
import 'enums/Weapons.dart';
import 'instances/game.dart';
import 'state.dart';


final StringBuffer _buffer = StringBuffer();
final gameUpdateIndex = ClientRequest.Game_Update.index;
const String _space = " ";

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

void sendRequestUpdateLobby(){
  send('${ClientRequest.Lobby_Update.index.toString()} ${state.lobby.uuid} ${state.lobby.playerUuid}');
}

void sendRequestJoinGame(String gameUuid){
  send('${ClientRequest.Game_Join.index.toString()} $gameUuid');
}

void sendRequestLobbyExit(){
  if(state.lobby == null){
    print("sendRequestLobbyExit() state.lobby is null");
    return;
  }
  send('${ClientRequest.Lobby_Exit.index.toString()} ${state.lobby.uuid} ${state.lobby.playerUuid}');
}

void sendRequestEquipMachineGun() {
  sendRequestEquip(Weapon.MachineGun);
}

void requestThrowGrenade(double strength){
  send('${ClientRequest.Player_Throw_Grenade.index} $session ${strength.toStringAsFixed(1)} ${requestAim.toStringAsFixed(2)}');
}

void sendRequestUpdatePlayer() {
  _buffer.clear();
  _write(gameUpdateIndex);
  _write(compiledGame.gameId);
  _write(compiledGame.playerId);
  _write(compiledGame.playerUUID);
  _write(requestCharacterState);
  _write(requestDirection);
  if(requestCharacterState == characterStateFiring){
    _write(requestAim.toStringAsFixed(2));
  }else{
    _write(requestAim.toInt());
  }
  _write(serverFrame);
  send(_buffer.toString());
}

void sendRequestJoinGameFortress(){
  send(ClientRequest.Game_Join_Fortress.index.toString());
}

void sendRequestJoinLobby(){
  send(ClientRequest.Lobby_Join.index.toString());
}

void sendRequestCreateLobby(){
  send(ClientRequest.Lobby_Create.index.toString());
}

void requestJoinRandomGame() {
  send(ClientRequest.Game_Join_Random.index.toString());
}

void sendRequestSpawn() {
  print("sendRequestSpawn()");
  send('spawn');
}

void sendRequestSpawnNpc() {
  send('${ClientRequest.Spawn_Npc.index} $session');
}

void _write(dynamic value) {
  _buffer.write(value);
  _buffer.write(_space);
}

void request(ClientRequest request, String value){
  send('${request.index} $value');
}

