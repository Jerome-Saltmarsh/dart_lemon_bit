import 'dart:typed_data';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/character_controller.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

import 'web_socket.dart';

final _gameUpdateIndex = ClientRequest.Update.index;
final _updateBuffer = Uint8List(16);

void sendRequestSpeak(String message){
  if (message.isEmpty) return;
  webSocket.send('${ClientRequest.Speak.index} $message');
}

void sendRequestTeleport(){
  sendClientRequest(ClientRequest.Teleport);
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

void sendRequestAttackSecondary() {
  sendClientRequest(ClientRequest.Attack_Secondary);
}

void sendRequestConstruct(int value) {
  sendClientRequest(ClientRequest.Construct, value);
}

void sendClientRequestSelectCharacterType(CharacterSelection value) {
  sendClientRequest(ClientRequest.Select_Character_Type, value.index);
}

void sendClientRequestSetBlock(int row, int column, int z, int type) {
  sendClientRequest(ClientRequest.Set_Block, '$row $column $z $type');
}

void sendClientRequestDeckAddCard(CardType value){
  sendClientRequest(ClientRequest.Deck_Add_Card, value.index);
}

void sendClientRequestDeckSelectCard(int index) {
  sendClientRequest(ClientRequest.Deck_Select_Card, index);
}

void sendClientRequestReverseHour(){
   sendClientRequest(ClientRequest.Reverse_Hour);
}

void sendClientRequestSkipHour(){
  sendClientRequest(ClientRequest.Skip_Hour);
}


void sendClientRequestSpawnZombie({
  required int z,
  required int row,
  required int column
}){
  sendClientRequest(ClientRequest.Spawn_Zombie, '$z $row $column');
}

void sendClientRequestSetWeapon(int type){
  sendClientRequest(ClientRequest.Set_Weapon, type);
}

void sendClientRequestSetArmour(int type){
  sendClientRequest(ClientRequest.Set_Armour, type);
}

void sendClientRequest(ClientRequest value, [dynamic message]){
  if (message != null){
    return webSocket.send('${value.index} $message');
  }
  webSocket.send(value.index);
}

class Server {
  static void upgradePickaxe() => upgrade(TechType.Pickaxe);
  static void upgradeSword() => upgrade(TechType.Sword);
  static void upgradeBow() => upgrade(TechType.Bow);
  static void equipPickaxe() => equip(TechType.Pickaxe);
  static void equipSword() => equip(TechType.Sword);
  static void equipBow() => equip(TechType.Bow);

  static void upgrade(int value){
    sendClientRequest(ClientRequest.Upgrade, value);
  }

  static void equip(int value){
    sendClientRequest(ClientRequest.Equip, value);
  }
}

final _screen = engine.screen;

Future sendRequestUpdatePlayer() async {
  _updateBuffer[0] = _gameUpdateIndex;
  _updateBuffer[1] = characterAction;
  writeNumberToByteArray(number: mouseGridX, list: _updateBuffer, index: 2);
  writeNumberToByteArray(number: mouseGridY, list: _updateBuffer, index: 4);
  if (characterAction == CharacterAction.Run){
    _updateBuffer[6] = characterDirection.toInt();
  } else {
    _updateBuffer[6] = 0;
  }

  writeNumberToByteArray(number: _screen.left, list: _updateBuffer, index: 7);
  writeNumberToByteArray(number: _screen.top, list: _updateBuffer, index: 9);
  writeNumberToByteArray(number: _screen.right, list: _updateBuffer, index: 11);
  writeNumberToByteArray(number: _screen.bottom, list: _updateBuffer, index: 13);

  webSocket.sink.add(_updateBuffer);
  characterAction = CharacterAction.Idle;
}

void sendRequestTogglePaths() {
  modules.game.state.debug.value = false;
  webSocket.send('${ClientRequest.Toggle_Debug.index}');
}

void request(ClientRequest request, String value) {
  webSocket.send('${request.index} $value');
}
