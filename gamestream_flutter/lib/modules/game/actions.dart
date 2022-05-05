
import 'package:bleed_common/CharacterAction.dart';
import 'package:bleed_common/ClientRequest.dart';
import 'package:bleed_common/Modify_Game.dart';
import 'package:bleed_common/SlotTypeCategory.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/modules/isometric/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/web_socket.dart';
import 'package:lemon_engine/engine.dart';

import 'state.dart';

final _bulletHoles = game.bulletHoles;
final _action = modules.game.state.characterController.action;

class GameActions {

  final GameState state;

  GameActions(this.state);

  void spawnBulletHole(double x, double y){
    final bulletHole = _bulletHoles[game.bulletHoleIndex];
    bulletHole.x = x;
    bulletHole.y = y;
    game.bulletHoleIndex++;
    game.bulletHoleIndex %= _bulletHoles.length;
  }

  void playerPerform() {
    final structureType = modules.game.structureType.value;
    if (structureType != null) {
      sendRequestConstruct(structureType);
      modules.game.structureType.value = null;
      return;
    }
    setCharacterAction(CharacterAction.Perform);
  }

  void playerRun() {
    setCharacterAction(CharacterAction.Run);
  }

  void emitPixelExplosion(double x, double y, {int amount = 10}) {
    for (var i = 0; i < amount; i++) {
      modules.game.factories.emitPixel(x: x, y: y);
    }
  }

  void setCharacterAction(int value){
    if (value < _action.value) return;
    _action.value = value;
  }

  void setCharacterActionRun(){
    setCharacterAction(CharacterAction.Run);
  }

  void setCharacterActionPerform(){
    setCharacterAction(CharacterAction.Perform);
  }

  void teleportToMouse() {
    sendRequestTeleport(mouseWorldX, mouseWorldY);
  }

  void toggleMessageBox() {
    state.textBoxVisible.value = !state.textBoxVisible.value;
  }

  void skipHour(){
    webSocket.send(ClientRequest.Skip_Hour.index.toString());
  }

  void reverseHour(){
    webSocket.send(ClientRequest.Reverse_Hour.index.toString());
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

  void showTextBox(){
    state.textBoxVisible.value = true;
  }

  void hideTextBox(){
    state.textBoxVisible.value = false;
  }

  void sendAndCloseTextBox(){
    print("sendAndCloseTextBox()");
    sendRequestSpeak(state.textEditingControllerMessage.text);
    hideTextBox();
  }

  void sellSlotItem(int index){
    print("game.actions.sellSlotItem($index)");
    _verifyValidSlotIndex(index);
    sendClientRequest(ClientRequest.Sell_Slot, index);
  }

  void equipSlot1(){
    equipSlot(1);
  }

  void equipSlot2(){
    equipSlot(2);
  }

  void equipSlot3(){
    equipSlot(3);
  }

  void equipSlot4(){
    equipSlot(4);
  }

  void equipSlot5(){
    equipSlot(5);
  }

  void equipSlot6(){
    equipSlot(6);
  }

  void toggleDebugPanel(){
    print("game.actions.toggleDebugPanel()");
    state.debugPanelVisible.value = !state.debugPanelVisible.value;
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

  void toggleDebugPaths() {
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