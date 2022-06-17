
import 'package:bleed_common/ClientRequest.dart';
import 'package:bleed_common/Modify_Game.dart';
import 'package:bleed_common/SlotTypeCategory.dart';
import 'package:gamestream_flutter/isometric/message_box.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/isometric/enums/camera_mode.dart';
import 'package:gamestream_flutter/modules/game/emit_particle.dart';
import 'package:gamestream_flutter/client_request_sender.dart';
import 'package:gamestream_flutter/web_socket.dart';

import 'state.dart';

final _bulletHoles = serverResponseReader.bulletHoles;

class GameActions {

  final GameState state;

  GameActions(this.state);

  void spawnBulletHole(double x, double y){
    final bulletHole = _bulletHoles[serverResponseReader.bulletHoleIndex];
    bulletHole.x = x;
    bulletHole.y = y;
    serverResponseReader.bulletHoleIndex++;
    serverResponseReader.bulletHoleIndex %= _bulletHoles.length;
  }

  void emitPixelExplosion(double x, double y, {int amount = 10}) {
    for (var i = 0; i < amount; i++) {
      emitParticlePixel(x: x, y: y);
    }
  }

  void toggleObjectsDestroyable(){
    webSocket.send(ClientRequest.Toggle_Objects_Destroyable.index.toString());
  }

  void selectAbility1() {
    sendRequestSelectAbility(1);
  }

  void selectAbility2() {
    sendRequestSelectAbility(2);
  }

  void selectAbility3() {
    sendRequestSelectAbility(3);
  }

  void selectAbility4() {
    sendRequestSelectAbility(4);
  }

  void purchaseSlotType(int slotType) {
    webSocket.send('${ClientRequest.Purchase.index} $slotType');
  }

  void playerEquip(int index) {
    print("game.actions.playerEquip(index: $index)");
    // webSocket.send('${ClientRequest.Equip.index} $session ${index - 1}');
  }

  void deselectAbility() {
    print("game.actions.deselectAbility()");
    // webSocket.send('${ClientRequest.DeselectAbility.index} $session');
  }

  void sendAndCloseTextBox(){
    print("sendAndCloseTextBox()");
    sendRequestSpeak(state.textEditingControllerMessage.text);
    messageBoxHide();
  }

  void sellSlotItem(int index){
    print("game.actions.sellSlotItem($index)");
    _verifyValidSlotIndex(index);
    sendClientRequest(ClientRequest.Sell_Slot, index);
  }

  void equipSlot1(){
    // equipSlot(1);
    sendClientRequestDeckSelectCard(0);
  }

  void equipSlot2(){
    sendClientRequestDeckSelectCard(1);
  }

  void equipSlot3(){
    sendClientRequestDeckSelectCard(2);
  }

  void equipSlot4(){
    sendClientRequestDeckSelectCard(3);
  }

  void equipSlot5(){
    equipSlot(5);
  }

  void equipSlot6(){
    equipSlot(6);
  }

  void nextCameraMode(){
    state.cameraMode.value = cameraModes[(state.cameraMode.value.index + 1) % cameraModes.length];
  }

  /// valid between 1 and 6 inclusive
  void equipSlot(int index){
    _verifyValidSlotIndex(index);
    sendClientRequest(ClientRequest.Equip_Slot, index);
  }

  void unequipWeapon(){
    unequip(SlotTypeCategory.Weapon);
  }

  void unequipArmour(){
    unequip(SlotTypeCategory.Armour);
  }

  void unequipHelm(){
    unequip(SlotTypeCategory.Helm);
  }

  void unequip(SlotTypeCategory value){
    print("game.actions.unequip(${value.name})");
    sendClientRequest(ClientRequest.Unequip_Slot, value.index);
  }

  void _verifyValidSlotIndex(int index){
      if (index <= 0 || index > 6)
        throw Exception("Slot item index must between 1 and 6 inclusive. (received $index)");
  }

  void toggleDebugMode() {
    print("game.actions.enableDebugNpc()");
    sendRequestTogglePaths();
  }

  spawnZombie(){
    modifyGame(ModifyGame.Spawn_Zombie);
  }

  modifyGame(ModifyGame request){
    sendClientRequest(ClientRequest.Modify_Game, request.index);
  }

  void sendClientRequest(ClientRequest request, dynamic value){
    webSocket.send('${request.index} $value');
  }

  void respawn() {
    webSocket.sink.add(ClientRequest.Revive.index);
  }
}