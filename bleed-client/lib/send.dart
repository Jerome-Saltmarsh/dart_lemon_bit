import 'package:bleed_client/common/CharacterAction.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';
import 'package:vector_math/vector_math_64.dart';

import 'common/GameType.dart';
import 'cube/camera3d.dart';
import 'webSocket.dart';

final StringBuffer _buffer = StringBuffer();
final gameUpdateIndex = ClientRequest.Update.index;
const _space = " ";

final _SendRequestToServer sendRequest = _SendRequestToServer();

String get session => game.session;

void speak(String message){
  if (message.isEmpty) return;
  webSocket.send('${ClientRequest.Speak.index} $session $message');
}

void sendRequestPing(){
  webSocket.sinkMessage(ClientRequest.Ping.index.toString());
}

void sendRequestTeleport(double x, double y){
  webSocket.send('${ClientRequest.Teleport.index} $session ${x.toInt()} ${y.toInt()} ');
}

void sendRequestSelectAbility(int index) {
  if (index < 1 || index > 4){
    throw Exception("sendRequestSelectAbility(index: $index) - index must be between 1 and 4 inclusive");
  }
  webSocket.send('${ClientRequest.SelectAbility.index} $session $index');
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

final _characterController = modules.game.state.characterController;

void sendRequestUpdatePlayer() {
  _buffer.clear();
  _write(gameUpdateIndex);
  _write(session);
  _write(_characterController.action.value.index);
  _characterController.action.value = CharacterAction.Idle;
  _write(_characterController.angle.toStringAsFixed(1));
  _write(mouseWorldX.toInt());
  _write(mouseWorldY.toInt());
  webSocket.send(_buffer.toString());
}

void sendRequestSetCompilePaths(bool value) {
  isometric.state.paths.clear();
  webSocket.send('${ClientRequest.SetCompilePaths.index} $session ${value ? 1 : 0}');
}

void sendClientRequest(ClientRequest request, [dynamic message = ""]) {
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
    sendClientRequest(ClientRequest.Upgrade_Ability, index);
  }
}

void sendRequestUpdateCube3D(){
  _write(ClientRequest.Update_Cube3D.index);
  _write(modules.game.state.player.uuid.value);
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