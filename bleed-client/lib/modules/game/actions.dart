
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/ui/logic/showTextBox.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:lemon_math/randomItem.dart';
import 'package:bleed_client/common/CharacterAction.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/functions/emit/emitPixel.dart';
import 'package:bleed_client/modules/game/state.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:lemon_engine/engine.dart';

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
    engine.actions.cameraCenter(game.player.x, game.player.y);
  }

  void emitPixelExplosion(double x, double y, {int amount = 10}) {
    for (int i = 0; i < amount; i++) {
      emitPixel(x: x, y: y);
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
    hud.state.textBoxVisible.value ? sendAndCloseTextBox() : showTextBox();
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

  void sendRequestCastFireball(){
    // send('${ClientRequest.CasteFireball.index} $session $aim');
  }

  void playerEquip(int index) {
    webSocket.send('${ClientRequest.Equip.index} $session ${index - 1}');
  }

  void playerDeselectAbility() {
    webSocket.send('${ClientRequest.DeselectAbility.index} $session');
  }

  void registerPlayKeyboardHandler() {
    print("registerPlayKeyboardHandler()");
    // RawKeyboard.instance.addListener(_keyboardEventHandlerPlayMode);
  }

  void registerTextBoxKeyboardHandler(){
    RawKeyboard.instance.addListener(_handleKeyboardEventTextBox);
  }

  void deregisterTextBoxKeyboardHandler(){
    RawKeyboard.instance.removeListener(_handleKeyboardEventTextBox);
  }

  void deregisterPlayKeyboardHandler() {
    print("deregisterPlayKeyboardHandler()");
    RawKeyboard.instance.removeListener(_keyboardEventHandlerPlayMode);
  }


  void _keyboardEventHandlerPlayMode(RawKeyEvent event) {
    if (event is RawKeyUpEvent) {
      _handleKeyUpEventPlayMode(event);
    } else if (event is RawKeyDownEvent) {
      _handleKeyDownEventPlayMode(event);
    }
  }

  void _handleKeyboardEventTextBox(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        sendAndCloseTextBox();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        hideTextBox();
      }
    }
  }

  void _handleKeyDownEventPlayMode(RawKeyDownEvent event) {
    LogicalKeyboardKey key = event.logicalKey;

    if (key == LogicalKeyboardKey.enter){
      if (hud.state.textBoxVisible.value){
        sendAndCloseTextBox();
      }
    }

    // // on key pressed
    // if (modules.game.map.keyPressedHandlers.containsKey(key)) {
    //   modules.game.map.keyPressedHandlers[key]?.call();
    // }
  }

  void _handleKeyUpEventPlayMode(RawKeyUpEvent event) {
    LogicalKeyboardKey key = event.logicalKey;

    if (hud.state.textBoxVisible.value) return;
  }
}