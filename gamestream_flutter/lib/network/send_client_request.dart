import 'dart:typed_data';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/character_controller.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:lemon_engine/screen.dart';

import 'web_socket.dart';

final updateBuffer = Uint8List(16);

void sendRequestSpeak(String message){
  if (message.trim().isEmpty) return;
  sendClientRequest(ClientRequest.Speak, message);
}

void sendClientRequestTeleport(){
  sendClientRequest(ClientRequest.Teleport);
}

void sendClientRequestAttack() {
  sendClientRequest(ClientRequest.Attack);
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

void sendClientRequestStoreClose(){
  sendClientRequest(ClientRequest.Store_Close);
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

void sendClientRequestPurchaseWeapon(int type){
  sendClientRequest(ClientRequest.Purchase_Weapon, type);
}

void sendClientRequestSetArmour(int type){
  sendClientRequest(ClientRequest.Set_Armour, type);
}

void sendClientRequestSetHeadType(int type){
  sendClientRequest(ClientRequest.Set_Head_Type, type);
}

void sendClientRequestSetPantsType(int type){
  sendClientRequest(ClientRequest.Set_Pants_Type, type);
}

void sendClientRequestUpgradeWeaponDamage(){
  sendClientRequest(ClientRequest.Upgrade_Weapon_Damage);
}

void sendClientRequestEquipWeapon(int index){
  assert (index >= 0);
  sendClientRequest(ClientRequest.Equip_Weapon, index);
}

void sendClientRequestWeatherSetRain(Rain value){
  sendClientRequest(ClientRequest.Weather_Set_Rain, value.index);
}

void sendClientRequestWeatherToggleBreeze(){
  sendClientRequest(ClientRequest.Weather_Toggle_Breeze);
}

void sendClientRequestWeatherSetWind(Wind wind){
  sendClientRequest(ClientRequest.Weather_Set_Wind, wind.index);
}

void sendClientRequestWeatherSetLightning(Lightning value){
  sendClientRequest(ClientRequest.Weather_Set_Lightning, value.index);
}

void sendClientRequestWeatherToggleTimePassing(){
  sendClientRequest(ClientRequest.Weather_Toggle_Time_Passing);
}

void sendClientRequestCustomGameNames(){
  sendClientRequest(ClientRequest.Custom_Game_Names);
}

void sendClientRequestEditorLoadGame(String name){
  sendClientRequest(ClientRequest.Editor_Load_Game, name);
}

void sendClientRequestEditorSetSceneName(String name){
  sendClientRequest(ClientRequest.Editor_Set_Scene_Name, name);
}

void sendClientRequestSubmitPlayerDesign(){
  sendClientRequest(ClientRequest.Submit_Player_Design);
}

void sendClientRequestTimeSetHour(int hour){
  assert(hour >= 0);
  assert(hour <= 24);
  sendClientRequest(ClientRequest.Time_Set_Hour, hour);
}

void sendClientRequestRespawn(){
 sendClientRequest(ClientRequest.Revive);
}

Future sendClientRequestUpdate() async {
  const updateIndex = 0;
  updateBuffer[0] = updateIndex;
  updateBuffer[1] = characterAction;
  writeNumberToByteArray(number: mouseGridX, list: updateBuffer, index: 2);
  writeNumberToByteArray(number: mouseGridY, list: updateBuffer, index: 4);
  if (characterAction == CharacterAction.Run){
    updateBuffer[6] = characterDirection.toInt();
  } else {
    updateBuffer[6] = 0;
  }
  writeNumberToByteArray(number: screen.left, list: updateBuffer, index: 7);
  writeNumberToByteArray(number: screen.top, list: updateBuffer, index: 9);
  writeNumberToByteArray(number: screen.right, list: updateBuffer, index: 11);
  writeNumberToByteArray(number: screen.bottom, list: updateBuffer, index: 13);
  webSocket.sink.add(updateBuffer);
  characterAction = CharacterAction.Idle;
}

void sendClientRequestTogglePaths() {
  sendClientRequest(ClientRequest.Toggle_Debug);
}

void sendClientRequest(ClientRequest value, [dynamic message]){
  if (message != null){
    return webSocket.send('${value.index} $message');
  }
  webSocket.send(value.index);
}