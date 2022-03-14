import 'dart:typed_data';

import 'package:bleed_client/common/CharacterAction.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/compile_util.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

import 'common/GameType.dart';
import 'webSocket.dart';

final _gameUpdateIndex = ClientRequest.Update.index;
final _buffer1 = Uint8List(1);
final _buffer9 = Uint8List(22);

void speak(String message){
  if (message.isEmpty) return;
  webSocket.send('${ClientRequest.Speak.index} $message');
}

void sendRequestPing(){
  print("ping()");
  _buffer1[0] = ClientRequest.Ping.index;
  webSocket.sink.add(_buffer1);
}

void sendRequestTeleport(double x, double y){
  print("sendRequestTeleport($x, $y)");
  webSocket.send('${ClientRequest.Teleport.index} ${x.toInt()} ${y.toInt()}');
}

void sendRequestSelectAbility(int index) {
  // if (index < 1 || index > 4){
  //   throw Exception("sendRequestSelectAbility(index: $index) - index must be between 1 and 4 inclusive");
  // }
  // webSocket.send('${ClientRequest.SelectAbility.index} $session $index');
}

void sendRequestJoinGame(GameType type) {
  final account = core.state.account.value;
  if (account != null) {
    webSocket.send('${ClientRequest.Join.index} ${type.index} ${account.userId}');
  } else {
    webSocket.send('${ClientRequest.Join.index} ${type.index}');
  }
}

void sendRequestCharacterSave(){
  webSocket.send(ClientRequest.Character_Save.index);
}

void sendRequestCharacterLoad(){
  webSocket.send(ClientRequest.Character_Load.index);
}

void sendRequestJoinCustomGame({required String mapName, required String playerId}) {
  print("sendRequestJoinCustomGame()");
  webSocket.send('${ClientRequest.Join_Custom.index} $playerId $mapName');
}

void sendRequestAcquireAbility(WeaponType type) {
  // webSocket.send('${ClientRequest.AcquireAbility.index} $session ${type.index}');
}

final _characterController = modules.game.state.characterController;
final _characterControllerAction = _characterController.action;

void sendRequestUpdatePlayer() {
  _buffer9[0] = _gameUpdateIndex;
  _buffer9[1] = _characterControllerAction.value.index;
  writeNumberToByteArray(number: mouseWorldX, list: _buffer9, index: 2);
  writeNumberToByteArray(number: mouseWorldY, list: _buffer9, index: 5);
  if (_characterControllerAction.value == CharacterAction.Run){
    _buffer9[8] = _characterController.angle.toInt();
  } else {
    _buffer9[8] = 0;
  }

  final screen = engine.screen;
  writeNumberToByteArray(number: screen.left, list: _buffer9, index: 9);
  writeNumberToByteArray(number: screen.top, list: _buffer9, index: 12);
  writeNumberToByteArray(number: screen.right, list: _buffer9, index: 15);
  writeNumberToByteArray(number: screen.bottom, list: _buffer9, index: 18);

  // _buffer9[22] = _player.byteId[0];
  // _buffer9[23] = _player.byteId[1];
  // _buffer9[24] = _player.byteId[2];
  // _buffer9[25] = _player.byteId[3];

  webSocket.sink.add(_buffer9);
  _characterControllerAction.value = CharacterAction.Idle;
}

void sendRequestSetCompilePaths(bool value) {
  isometric.state.paths.clear();
}

void request(ClientRequest request, String value) {
  webSocket.send('${request.index} $value');
}

class _SendRequestToServer {
  upgradeAbility(int index){
    print("sendRequest.upgradeAbility(index: $index)");
  }
}
