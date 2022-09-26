import 'package:bleed_common/library.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric/message_box.dart';
import 'package:gamestream_flutter/isometric/watches/debug_visible.dart';
import 'package:lemon_engine/engine.dart';

void readPlayerInput() {

  if (keyPressed(LogicalKeyboardKey.keyO)) {
    debugVisible.value = true;
  }
  if (keyPressed(LogicalKeyboardKey.keyP)) {
    debugVisible.value = false;
  }

  if (game.edit.value) {
    return readPlayerInputEdit();
  }

  if (keyPressed(LogicalKeyboardKey.enter)){
    messageBoxShow();
  }
}

void readPlayerInputEdit() {
  if (keyPressed(LogicalKeyboardKey.space)) {
    engine.panCamera();
  }
  if (keyPressed(LogicalKeyboardKey.delete)) {
    edit.delete();
  }
  if (keyPressed(LogicalKeyboardKey.keyR)) {
    edit.nodeSelected.value = edit.nodeSelected.value;
  }
  if (getKeyDirection() != Direction.None) {
    actionSetModePlay();
  }
  return;
}

int getKeyDirection() {
  final keysPressed = keyboardInstance.keysPressed;

  if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      return Direction.East;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      return Direction.North;
    }
    return Direction.North_East;
  }

  if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      return Direction.South;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      return Direction.West;
    }
    return Direction.South_West;
  }
  if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
    return Direction.North_West;
  }
  if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
    return Direction.South_East;
  }
  return Direction.None;
}

