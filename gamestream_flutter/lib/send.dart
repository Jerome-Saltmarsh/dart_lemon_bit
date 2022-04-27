import 'dart:typed_data';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

import 'webSocket.dart';

final _gameUpdateIndex = ClientRequest.Update.index;
final _buffer1 = Uint8List(1);
final _updateBuffer = Uint8List(16);

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

void sendRequestAttack() {
  webSocket.send(ClientRequest.Attack.index);
}

void sendRequestConstruct(int value) {
  sendClientRequest(ClientRequest.Construct, value);
}

void sendClientRequest(ClientRequest value, [dynamic message]){
  if (message != null){
    return webSocket.send('${value.index} $message');
  }
  webSocket.send(value.index);
}

class Server {
  static void upgradePickaxe() => _upgrade(TechType.Pickaxe);
  static void upgradeSword() => _upgrade(TechType.Sword);
  static void equipPickaxe() => _equip(TechType.Pickaxe);
  static void equipSword() => _equip(TechType.Sword);

  static void _upgrade(int value){
    sendClientRequest(ClientRequest.Upgrade, value);
  }

  static void _equip(int value){
    sendClientRequest(ClientRequest.Equip, value);
  }
}

final _characterController = modules.game.state.characterController;
final _characterControllerAction = _characterController.action;
final _screen = engine.screen;

Future sendRequestUpdatePlayer() async {
  _updateBuffer[0] = _gameUpdateIndex;
  _updateBuffer[1] = _characterControllerAction.value;
  writeNumberToByteArray(number: mouseWorldX, list: _updateBuffer, index: 2);
  writeNumberToByteArray(number: mouseWorldY, list: _updateBuffer, index: 4);
  if (_characterControllerAction.value == CharacterAction.Run){
    _updateBuffer[6] = _characterController.angle.toInt();
  } else {
    _updateBuffer[6] = 0;
  }

  writeNumberToByteArray(number: _screen.left, list: _updateBuffer, index: 7);
  writeNumberToByteArray(number: _screen.top, list: _updateBuffer, index: 9);
  writeNumberToByteArray(number: _screen.right, list: _updateBuffer, index: 11);
  writeNumberToByteArray(number: _screen.bottom, list: _updateBuffer, index: 13);

  webSocket.sink.add(_updateBuffer);
  _characterControllerAction.value = CharacterAction.Idle;
}

void sendRequestTogglePaths() {
  modules.game.state.compilePaths.value = false;
  webSocket.send('${ClientRequest.Set_Compile_Paths.index}');
}

void request(ClientRequest request, String value) {
  webSocket.send('${request.index} $value');
}
