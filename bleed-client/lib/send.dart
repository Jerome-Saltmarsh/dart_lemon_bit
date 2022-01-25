import 'package:bleed_client/common/CharacterAction.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/Modify_Game.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/render/state/paths.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';
import 'package:vector_math/vector_math_64.dart';

import 'common/GameType.dart';
import 'cube/camera3d.dart';
import 'webSocket.dart';

final StringBuffer _buffer = StringBuffer();
final gameUpdateIndex = ClientRequest.Update.index;
const String _space = " ";

final _SendRequestToServer sendRequest = _SendRequestToServer();

String get session => game.session;

void speak(String message){
  if (message.isEmpty) return;
  webSocket.send('${ClientRequest.Speak.index} $session $message');
}

void sendRequestInteract(){
  webSocket.send('${ClientRequest.Interact.index} $session');
}

void sendRequestPing(){
  webSocket.sinkMessage(ClientRequest.Ping.index.toString());
}

void sendRequestRevive() {
  webSocket.send('${ClientRequest.Revive.index} $session');
}

void sendRequestTeleport(double x, double y){
  webSocket.send('${ClientRequest.Teleport.index} $session ${x.toInt()} ${y.toInt()} ');
}

void sendRequestCastFireball(){
  // send('${ClientRequest.CasteFireball.index} $session $aim');
}

void sendRequestEquip(int index) {
  webSocket.send('${ClientRequest.Equip.index} $session ${index - 1}');
}

void sendRequestDeselectAbility() {
  webSocket.send('${ClientRequest.DeselectAbility.index} $session');
}

void sendRequestSelectAbility(int index) {
  if (index < 1 || index > 4){
    throw Exception("sendRequestSelectAbility(index: $index) - index must be between 1 and 4 inclusive");
  }
  webSocket.send('${ClientRequest.SelectAbility.index} $session $index');
}

void skipHour(){
  webSocket.send(ClientRequest.SkipHour.index.toString());
}

void reverseHour(){
  webSocket.send(ClientRequest.ReverseHour.index.toString());
}


void requestThrowGrenade(double strength) {
  // send('${ClientRequest.Grenade.index} $session ${strength.toStringAsFixed(1)} $aim');
}

void sendRequestAcquireShotgun(){
  sendRequestAcquireAbility(WeaponType.Shotgun);
}

void sendRequestAcquireHandgun(){
  sendRequestAcquireAbility(WeaponType.HandGun);
}

void sendRequestJoinGame(GameType type, {String? playerId}) {
  if (playerId == null){
    webSocket.send('${ClientRequest.Join.index} ${type.index}');
  }else{
    webSocket.send('${ClientRequest.Join.index} ${type.index} $playerId');
  }
}

void sendRequestJoinCustomGame({required String mapName, required String playerId}) {
  print("sendRequestJoinCustomGame()");
  webSocket.send('${ClientRequest.Join_Custom.index} $playerId $mapName');
}

void sendRequestAcquireAbility(WeaponType type) {
  webSocket.send('${ClientRequest.AcquireAbility.index} $session ${type.index}');
}

void sendRequestUpdatePlayer() {
  _buffer.clear();
  _write(gameUpdateIndex);
  _write(session);
  _write(characterController.action.value.index);
  characterController.action.value = CharacterAction.Idle;
  _write(characterController.direction.index);
  _write(mouseWorldX.toInt());
  _write(mouseWorldY.toInt());
  webSocket.send(_buffer.toString());
}

void sendRequestSetCompilePaths(bool value) {
  paths.clear();
  webSocket.send('${ClientRequest.SetCompilePaths.index} $session ${value ? 1 : 0}');
}

void sendClientRequest(ClientRequest request, {dynamic message = ""}) {
  webSocket.send('${request.index} $session $message');
}

void _write(dynamic value) {
  _buffer.write(value);
  _buffer.write(_space);
}

void request(ClientRequest request, String value) {
  webSocket.send('${request.index} $value');
}

class _SendRequestToServer {
  upgradeAbility(int index){
    print("sendRequest.upgradeAbility(index: $index)");
    sendClientRequest(ClientRequest.Upgrade_Ability, message: index);
  }

  spawnZombie(){
    modifyGame(ModifyGame.Spawn_Zombie);
  }

  removeZombie(){
    modifyGame(ModifyGame.Remove_Zombie);
  }

  hourIncrease(){
    modifyGame(ModifyGame.Hour_Increase);
  }

  hourDecrease(){
    modifyGame(ModifyGame.Hour_Decrease);
  }

  modifyGame(ModifyGame request){
    print("sendRequest.modifyGame($request)");
    sendClientRequest(ClientRequest.Modify_Game, message: request.index);
  }
}

void sendRequestUpdateCube3D(){
  _write(ClientRequest.Update_Cube3D.index);
  _write(game.player.uuid.value);
  _writeVector3(camera3D.position);
  _writeVector3(camera3D.rotation);
  _sendAndClearBuffer();
}

void _sendAndClearBuffer(){
  webSocket.send(_buffer.toString());
  _buffer.clear();
}

void _writeVector3(Vector3 value){
  _write(value.x.toInt());
  _write(value.y.toInt());
  _write(value.z.toInt());
}