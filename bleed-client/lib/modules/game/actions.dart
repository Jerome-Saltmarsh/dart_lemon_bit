
import 'package:bleed_client/common/enums/Direction.dart';
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

  void showTextBox(){
    hud.state.textBoxVisible.value = true;
    modules.game.state.textFieldMessage.requestFocus();
  }

  void hideTextBox(){
    modules.game.state.textFieldMessage.unfocus();
    hud.state.textBoxVisible.value = false;
    hud.textEditingControllers.speak.text = "";
  }

  void sendAndCloseTextBox(){
    print("sendAndCloseTextBox()");
    speak(hud.textEditingControllers.speak.text);
    hideTextBox();
  }
}