import 'package:bleed_common/library.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/character_controller.dart';
import 'package:gamestream_flutter/isometric/message_box.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:lemon_engine/engine.dart';

void readPlayerInput() {

  if (playModeEdit) {
    if (engine.mouseRightDown.value || keyPressed(LogicalKeyboardKey.space)) {
      engine.panCamera();
    }
    return;
  }

  if (messageBoxVisible.value) return;

  if (engine.mouseLeftDown.value) {
    setCharacterActionPerform();
    return;
  }

  final direction = _getKeyDirection();
  if (direction != null) {
    characterDirection = direction;
    setCharacterActionRun();
  }
}

int? _getKeyDirection() {
  final keysPressed = keyboardInstance.keysPressed;

  if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      return Direction.North_East;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      return Direction.North_West;
    }
    return Direction.North;
  }

  if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      return Direction.South_East;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      return Direction.South_West;
    }
    return Direction.South;
  }
  if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
    return Direction.West;
  }
  if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
    return Direction.East;
  }
  return null;
}

