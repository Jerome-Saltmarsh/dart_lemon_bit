
import 'package:bleed_client/common/CharacterAction.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/Modify_Game.dart';
import 'package:bleed_client/common/SlotType.dart';
import 'package:bleed_client/common/SlotTypeCategory.dart';
import 'package:bleed_client/modules/game/state.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/randomItem.dart';

class GameActions {

  final GameState state;

  GameActions(this.state);

  void spawnBulletHole(double x, double y){
    game.bulletHoles[game.bulletHoleIndex].x = x;
    game.bulletHoles[game.bulletHoleIndex].y = y;
    game.bulletHoleIndex = (game.bulletHoleIndex + 1) % game.settings.maxBulletHoles;
  }

  void playerPerform() {
    setCharacterAction(CharacterAction.Perform);
  }

  void playerInteract(){
    webSocket.send('${ClientRequest.Interact.index} $session');
  }

  void cameraCenterPlayer(){
    engine.actions.cameraCenter(modules.game.state.player.x, modules.game.state.player.y);
  }

  void emitPixelExplosion(double x, double y, {int amount = 10}) {
    for (int i = 0; i < amount; i++) {
      modules.game.factories.emitPixel(x: x, y: y);
    }
  }

  void setCharacterAction(CharacterAction value){
    if (value.index < state.characterController.action.value.index) return;
    state.characterController.action.value = value;
  }

  void setCharacterActionRun(){
    setCharacterAction(CharacterAction.Run);
  }

  void teleportToMouse() {
    sendRequestTeleport(mouseWorldX, mouseWorldY);
  }

  void sayGreeting() {
    speak(randomItem(state.greetings));
  }

  void sayLetsGo() {
    speak(randomItem(state.letsGo));
  }

  void sayWaitASecond() {
    speak(randomItem(state.waitASecond));
  }

  void toggleMessageBox() {
    state.textMode.value = !state.textMode.value;
  }

  void toggleAudio(){
    print("game.actions.toggleAudio()");
    state.audioMuted.value = !state.audioMuted.value;
  }

  void skipHour(){
    webSocket.send(ClientRequest.SkipHour.index.toString());
  }

  void reverseHour(){
    webSocket.send(ClientRequest.ReverseHour.index.toString());
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

  void purchaseSlotType(SlotType slotType){
    print("game.actions.purchaseSlotType('${slotType.name}')");
    webSocket.send('${ClientRequest.Purchase.index} $session ${slotType.index}');
  }

  void playerEquip(int index) {
    webSocket.send('${ClientRequest.Equip.index} $session ${index - 1}');
  }

  void playerDeselectAbility() {
    webSocket.send('${ClientRequest.DeselectAbility.index} $session');
  }

  void showTextBox(){
    state.textMode.value = true;
  }

  void hideTextBox(){
    state.textMode.value = false;
  }

  void sendAndCloseTextBox(){
    print("sendAndCloseTextBox()");
    speak(state.textEditingControllerMessage.text);
    hideTextBox();
  }

  void sellSlotItem(int index){
    print("game.actions.sellSlotItem($index)");
    _verifyValidSlotIndex(index);
    sendClientRequest(ClientRequest.Sell_Slot, index);
  }

  /// valid between 1 and 6 inclusive
  void equipSlot(int index){
    print("game.actions.equipSlot($index)");
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
    sendRequestSetCompilePaths(!state.compilePaths.value);
  }

  spawnZombie(){
    modifyGame(ModifyGame.Spawn_Zombie);
  }

  modifyGame(ModifyGame request){
    print("sendRequest.modifyGame($request)");
    sendClientRequest(ClientRequest.Modify_Game, request.index);
  }

  void respawn() {
    webSocket.send('${ClientRequest.Revive.index} $session');
  }

}