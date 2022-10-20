import 'package:bleed_common/library.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/game_io.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
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

  if (Game.edit.value) {
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
    EditState.delete();
  }
  // if (keyPressed(LogicalKeyboardKey.keyR)) {
  //   edit.nodeSelectedIndex.value = edit.nodeSelectedIndex.value;
  // }
  if (GameIO.getKeyDirection() != Direction.None) {
    actionSetModePlay();
  }
  return;
}

// int getKeyDirection() {
//   final keysPressed = Engine.keyboard.keysPressed;
//
//   if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
//     if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
//       return Direction.East;
//     }
//     if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
//       return Direction.North;
//     }
//     return Direction.North_East;
//   }
//
//   if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
//     if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
//       return Direction.South;
//     }
//     if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
//       return Direction.West;
//     }
//     return Direction.South_West;
//   }
//   if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
//     return Direction.North_West;
//   }
//   if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
//     return Direction.South_East;
//   }
//   return Direction.None;
// }

