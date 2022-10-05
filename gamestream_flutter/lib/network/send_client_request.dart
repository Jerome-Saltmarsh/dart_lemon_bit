import 'dart:typed_data';

import 'package:bleed_common/gameobject_request.dart';
import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_size.dart';
import 'package:bleed_common/teleport_scenes.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric_web/read_player_input.dart';
import 'package:gamestream_flutter/network/instance/websocket.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/screen.dart';


final updateBuffer = Uint8List(17);

void sendRequestSpeak(String message){
  if (message.trim().isEmpty) return;
  sendClientRequest(ClientRequest.Speak, message);
}

void sendClientRequestTeleport(){
  sendClientRequest(ClientRequest.Teleport);
}

void sendClientRequestTeleportScene(TeleportScenes scene){
  sendClientRequest(ClientRequest.Teleport_Scene, scene.index);
}

void sendClientRequestSpawnNodeData(int z, int row, int column){
  sendClientRequest(ClientRequest.Spawn_Node_Data, '$z $row $column');
}

void sendClientRequestStoreClose(){
  sendClientRequest(ClientRequest.Store_Close);
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

void sendClientRequestSetCanvasSize(int z, int rows, int columns){
  sendClientRequest(ClientRequest.Editor_Set_Canvas_Size, '$z $rows $columns');
}

/// dimension: 0 == Z; 1 == Row; 2 == Column;
/// add: true means add; false means remove;
/// start: true means insert at the beginning; false means add to the end
void sendClientRequestCanvasModifySize({
  required int dimension,
  required bool add,
  required bool start,
}) {
  sendClientRequest(ClientRequest.Canvas_Modify_Size, '$dimension ${add ? 1 : 0} ${start ? 1 : 0}');
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

void sendClientRequestWeatherToggleTimePassing([bool? value]){
  sendClientRequest(ClientRequest.Weather_Toggle_Time_Passing, value);
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

void sendClientRequestNpcSelectTopic(int index) =>
   sendClientRequest(ClientRequest.Npc_Talk_Select_Option, index);

void sendClientRequestTimeSetHour(int hour){
  assert(hour >= 0);
  assert(hour <= 24);
  sendClientRequest(ClientRequest.Time_Set_Hour, hour);
}

void sendClientRequestRespawn(){
 sendClientRequest(ClientRequest.Revive);
}

void sendClientRequestSetBlock({
  required int index,
  required int type,
  required int orientation,
}) =>
  sendClientRequest(
      ClientRequest.Node,
      '$index $type $orientation',
  );

void sendClientRequestAddGameObject({
  required int z,
  required int row,
  required int column,
  required int type,
}) {
  final posZ = convertIndexToZ(z);
  final posX = convertIndexToX(row);
  final posY = convertIndexToY(column);

  sendClientRequest(
    ClientRequest.GameObject,
    "${GameObjectRequest.Add.index} $posX $posY $posZ $type",
  );
}

void sendClientRequestAddGameObjectXYZ({
  required double x,
  required double y,
  required double z,
  required int type,
}) {
  sendClientRequest(
      ClientRequest.GameObject,
      "${GameObjectRequest.Add.index} $x $y $z $type",
  );
}

void sendClientRequestGameObjectTranslate({
  required double tx,
  required double ty,
  required double tz,
}) {
  sendClientRequest(
    ClientRequest.GameObject,
    "${GameObjectRequest.Translate.index} $tx $ty $tz",
  );
}

void sendGameObjectRequestSelect() {
  sendGameObjectRequest(GameObjectRequest.Select);
}

void sendGameObjectRequestDeselect() {
  sendGameObjectRequest(GameObjectRequest.Deselect);
}

void sendGameObjectRequestDelete() {
  sendGameObjectRequest(GameObjectRequest.Delete);
}

void sendClientRequestSpawnNodeDataModify({
  required int z,
  required int row,
  required int column,
  required int spawnType,
  required int spawnAmount,
  required int spawnRadius,
}) =>
  sendClientRequest(
      ClientRequest.Spawn_Node_Data_Modify,
      '$z $row $column $spawnType $spawnAmount $spawnRadius'
  );

void sendGameObjectRequestMoveToMouse() {
  sendGameObjectRequest(GameObjectRequest.Move_To_Mouse);
}

void sendGameObjectRequest(GameObjectRequest request, [dynamic message]) {
  if (message != null){
    sendClientRequest(ClientRequest.GameObject, '${request.index} $message');
  }
  sendClientRequest(ClientRequest.GameObject, request.index);
}

Future sendClientRequestUpdate() async {
  const updateIndex = 0;

  updateBuffer[0] = updateIndex;
  updateBuffer[1] = getKeyDirection();
  updateBuffer[2] = !game.edit.value && engine.mouseLeftDown.value ? 1 : 0;
  updateBuffer[3] = !game.edit.value && engine.mouseRightDown.value ? 1 : 0;
  updateBuffer[4] = !game.edit.value && keyPressedSpace ? 1 : 0;
  writeNumberToByteArray(number: mouseWorldX, list: updateBuffer, index: 5);
  writeNumberToByteArray(number: mouseWorldY, list: updateBuffer, index: 7);
  writeNumberToByteArray(number: screen.left, list: updateBuffer, index: 9);
  writeNumberToByteArray(number: screen.top, list: updateBuffer, index: 11);
  writeNumberToByteArray(number: screen.right, list: updateBuffer, index: 13);
  writeNumberToByteArray(number: screen.bottom, list: updateBuffer, index: 15);

  webSocket.sink.add(updateBuffer);
}

bool get keyPressedSpace => keyPressed(LogicalKeyboardKey.space);

void sendClientRequestTogglePaths() {
  sendClientRequest(ClientRequest.Toggle_Debug);
}

void sendClientRequest(ClientRequest value, [dynamic message]){
  if (message != null){
    return webSocket.send('${value.index} $message');
  }
  webSocket.send(value.index);
}