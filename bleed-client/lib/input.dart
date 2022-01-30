import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:flutter/services.dart';

import 'common/enums/Direction.dart';
import 'ui/logic/showTextBox.dart';

final RawKeyboard rawKeyboard = RawKeyboard.instance;

void registerKeyboardHandler(Function(RawKeyEvent event) handler) {
  rawKeyboard.addListener(handler);
}

void deregisterKeyboardHandler(Function(RawKeyEvent event) handler) {
  rawKeyboard.removeListener(handler);
}

void stopRunLeft() {
  modules.game.actions.setCharacterActionRun();
  setCharacterDirection(Direction.Left);
}

void setCharacterDirection(Direction value){
  modules.game.state.characterController.direction = value;
}

