import 'package:bleed_common/library.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/isometric/watches/debug_visible.dart';
import 'package:lemon_engine/engine.dart';

void readPlayerInput() {

  if (Engine.keyPressed(LogicalKeyboardKey.keyO)) {
    debugVisible.value = true;
  }
  if (Engine.keyPressed(LogicalKeyboardKey.keyP)) {
    debugVisible.value = false;
  }

  if (GameState.edit.value) {
    return readPlayerInputEdit();
  }

  if (Engine.keyPressed(LogicalKeyboardKey.enter)){
    GameActions.messageBoxShow();
  }
}

void readPlayerInputEdit() {
  if (Engine.keyPressed(LogicalKeyboardKey.space)) {
    Engine.panCamera();
  }
  if (Engine.keyPressed(LogicalKeyboardKey.delete)) {
    GameEditor.delete();
  }
  if (GameIO.getDirectionKeyboard() != Direction.None) {
    GameActions.actionSetModePlay();
  }
  return;
}

