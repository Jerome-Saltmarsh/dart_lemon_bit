import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:flutter/services.dart';

import 'common/enums/Direction.dart';
import 'ui/logic/showTextBox.dart';

final RawKeyboard rawKeyboard = RawKeyboard.instance;

void registerPlayKeyboardHandler() {
  print("registerPlayKeyboardHandler()");
  registerKeyboardHandler(_keyboardEventHandlerPlayMode);
}

void registerTextBoxKeyboardHandler(){
  registerKeyboardHandler(_handleKeyboardEventTextBox);
}

void deregisterTextBoxKeyboardHandler(){
  deregisterKeyboardHandler(_handleKeyboardEventTextBox);
}

void deregisterPlayKeyboardHandler() {
  print("deregisterPlayKeyboardHandler()");
  deregisterKeyboardHandler(_keyboardEventHandlerPlayMode);
}

void registerKeyboardHandler(Function(RawKeyEvent event) handler) {
  rawKeyboard.addListener(handler);
}

void deregisterKeyboardHandler(Function(RawKeyEvent event) handler) {
  rawKeyboard.removeListener(handler);
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

void stopRunLeft() {
  modules.game.actions.setCharacterActionRun();
  setCharacterDirection(Direction.Left);
}

void _handleKeyDownEventPlayMode(RawKeyDownEvent event) {
  LogicalKeyboardKey key = event.logicalKey;

  if (key == LogicalKeyboardKey.enter){
    if (hud.state.textBoxVisible.value){
      sendAndCloseTextBox();
    }
  }

  // on key pressed
  if (modules.game.map.keyPressedHandlers.containsKey(key)) {
    modules.game.map.keyPressedHandlers[key]?.call();
  }
}

// on text box visible should disable the character keyboard and vicer vercer

void _handleKeyUpEventPlayMode(RawKeyUpEvent event) {
  LogicalKeyboardKey key = event.logicalKey;

  if (hud.state.textBoxVisible.value) return;
}


void setCharacterDirection(Direction value){
  modules.game.state.characterController.direction = value;
}

