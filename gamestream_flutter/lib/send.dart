import 'dart:typed_data';

import 'package:bleed_common/CharacterAction.dart';
import 'package:bleed_common/ClientRequest.dart';
import 'package:bleed_common/GameType.dart';
import 'package:bleed_common/WeaponType.dart';
import 'package:bleed_common/compile_util.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

import 'webSocket.dart';

final _gameUpdateIndex = ClientRequest.Update.index;
final _buffer1 = Uint8List(1);
final _updateBuffer = Uint8List(16);

// final _serverFrames = modules.game.state.player.serverFrame;

void sendRequestSpeak(String message){
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

void sendRequestAttack() {
  webSocket.send(ClientRequest.Attack.index);
}

final _characterController = modules.game.state.characterController;
final _characterControllerAction = _characterController.action;

Future sendRequestUpdatePlayer() async {
  final screen = engine.screen;

  _updateBuffer[0] = _gameUpdateIndex;
  _updateBuffer[1] = _characterControllerAction.value;
  writeNumberToByteArray(number: mouseWorldX, list: _updateBuffer, index: 2);
  writeNumberToByteArray(number: mouseWorldY, list: _updateBuffer, index: 4);
  if (_characterControllerAction.value == CharacterAction.Run){
    _updateBuffer[6] = _characterController.angle.toInt();
  } else {
    _updateBuffer[6] = 0;
  }

  writeNumberToByteArray(number: screen.left, list: _updateBuffer, index: 7);
  writeNumberToByteArray(number: screen.top, list: _updateBuffer, index: 9);
  writeNumberToByteArray(number: screen.right, list: _updateBuffer, index: 11);
  writeNumberToByteArray(number: screen.bottom, list: _updateBuffer, index: 13);

  webSocket.sink.add(_updateBuffer);
  _characterControllerAction.value = CharacterAction.Idle;
}

void sendRequestTogglePaths() {
  modules.game.state.compilePaths.value = false;
  webSocket.send('${ClientRequest.SetCompilePaths.index}');
}

void request(ClientRequest request, String value) {
  webSocket.send('${request.index} $value');
}
