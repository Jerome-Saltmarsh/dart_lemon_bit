import 'package:bleed_common/library.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_io.dart';
import 'package:gamestream_flutter/game_editor.dart';
import 'package:gamestream_flutter/isometric/game.dart';
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
    messageBoxShow();
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
    actionSetModePlay();
  }
  return;
}

