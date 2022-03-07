import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_client/common/CharacterAction.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

import 'common/GameType.dart';
import 'webSocket.dart';

final gameUpdateIndex = ClientRequest.Update.index;
final sendRequest = _SendRequestToServer();

final _buffer1 = Int8List(1);
final _buffer2 = Int8List(2);
final _buffer3 = Int8List(3);
final _buffer4 = Int8List(4);
final _buffer5 = Int8List(5);
final _buffer6 = Int8List(6);
final _buffer7 = Int8List(7);
final _buffer8 = Int8List(8);
final _buffer9 = Int8List(9);

void speak(String message){
  // if (message.isEmpty) return;
  // webSocket.send('${ClientRequest.Speak.index} $session $message');
}

void sendRequestPing(){
  print("ping()");
  // webSocket.sinkMessage(ClientRequest.Ping.index.toString());
  _buffer1[0] = ClientRequest.Ping.index;
  webSocket.sink.add(_buffer1);
}

void sendRequestTeleport(double x, double y){
  print("sendRequestTeleport($x, $y)");
  _buffer3[0] = ClientRequest.Teleport.index;
  _buffer3[1] = x.toInt();
  _buffer3[2] = y.toInt();
  webSocket.sink.add(_buffer3);
  // webSocket.send('${ClientRequest.Teleport.index} $session ${} ${y.toInt()} ');
}

void sendRequestSelectAbility(int index) {
  // if (index < 1 || index > 4){
  //   throw Exception("sendRequestSelectAbility(index: $index) - index must be between 1 and 4 inclusive");
  // }
  // webSocket.send('${ClientRequest.SelectAbility.index} $session $index');
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
  _buffer2[0] = ClientRequest.Join.index;
  _buffer2[1] = type.index;
  webSocket.sink.add(_buffer2);
  return;
  if (playerId == null){
    // webSocket.send('${ClientRequest.Join.index} ${type.index}');
    _buffer2[0] = ClientRequest.Join.index;
    _buffer2[1] = type.index;
    webSocket.sink.add(_buffer2);

  } else {
    _buffer3[0] = ClientRequest.Join.index;
    _buffer3[1] = type.index;
    // _sendBuffer3[2] = playerId;
    // webSocket.sink.add(_sendBuffer2);
    // webSocket.send('${ClientRequest.Join.index} ${type.index} $playerId');
  }
}

void sendRequestJoinCustomGame({required String mapName, required String playerId}) {
  print("sendRequestJoinCustomGame()");
  webSocket.send('${ClientRequest.Join_Custom.index} $playerId $mapName');
}

void sendRequestAcquireAbility(WeaponType type) {
  // webSocket.send('${ClientRequest.AcquireAbility.index} $session ${type.index}');
}

final _characterController = modules.game.state.characterController;

const _256 = 256;

void compileDouble({required double value, required List<int> list, required int index}){
  final abs = value.toInt().abs();
  list[index] = value < 0 ? 0 : 1; // sign
  list[index + 1] = abs ~/ _256;  // count
  list[index + 2] = abs % _256;   // remainder
}

void sendRequestUpdatePlayer() {
  final x = mouseWorldX.toInt();
  final xSign = x < 0 ? 0 : 1;
  final xAbs = x.abs();
  final xCount = xAbs ~/ _256;
  final xRemainder = xAbs % _256;

  final y = mouseWorldY.toInt();
  final ySign = y < 0 ? 0 : 1;
  final yAbs = y.abs();
  final yCount = yAbs ~/ _256;
  final yRemainder = yAbs % _256;

  _buffer9[0] = gameUpdateIndex;
  _buffer9[1] = _characterController.action.value.index;

  _buffer9[2] = xSign;
  _buffer9[3] = xCount;
  _buffer9[4] = xRemainder;

  _buffer9[5] = ySign;
  _buffer9[6] = yCount;
  _buffer9[7] = yRemainder;

  if (_characterController.action.value == CharacterAction.Run){
    _buffer9[8] = _characterController.angle.toInt();
  } else {
    _buffer9[8] = 0;
  }

  // webSocket.send(_buffer.toString());
  // webSocket.sink.add(data)s
  webSocket.sink.add(_buffer9);

  _characterController.action.value = CharacterAction.Idle;
}

void sendRequestSetCompilePaths(bool value) {
  isometric.state.paths.clear();
  // webSocket.send('${ClientRequest.SetCompilePaths.index} $session ${value ? 1 : 0}');
}

// void sendClientRequest(ClientRequest request, [dynamic message = ""]) {
//   webSocket.send('${request.index} $session $message');
// }

// void _write(dynamic value) {
//   _buffer.write(value);
//   _buffer.write(_space);
// }

void request(ClientRequest request, String value) {
  webSocket.send('${request.index} $value');
}

class _SendRequestToServer {
  upgradeAbility(int index){
    print("sendRequest.upgradeAbility(index: $index)");
    // sendClientRequest(ClientRequest.Upgrade_Ability, index);
  }
}

// void sendRequestUpdateCube3D(){
//   _write(ClientRequest.Update_Cube3D.index);
//   _write(modules.game.state.player.uuid.value);
//   _writeVector3(camera3D.position);
//   _writeVector3(camera3D.rotation);
//   _sendAndClearBuffer();
// }

// void _sendAndClearBuffer(){
//   webSocket.send(_buffer.toString());
//   _buffer.clear();
// }

// void _writeVector3(Vector3 value){
//   _write(value.x.toInt());
//   _write(value.y.toInt());
//   _write(value.z.toInt());
// }