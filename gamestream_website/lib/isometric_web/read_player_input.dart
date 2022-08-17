import 'package:bleed_common/library.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/character_controller.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/message_box.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/watches/debug_visible.dart';
import 'package:gamestream_flutter/isometric_web/register_isometric_web_controls.dart';
import 'package:lemon_engine/engine.dart';

import '../isometric/watches/scene_meta_data.dart';
import '../network/send_client_request.dart';

void readPlayerInput() {

  if (keyPressed(LogicalKeyboardKey.keyO)) {
    debugVisible.value = true;
  }
  if (keyPressed(LogicalKeyboardKey.keyP)) {
    debugVisible.value = false;
  }

  if (playModeEdit) {
    if (keyPressed(LogicalKeyboardKey.space)) {
      engine.panCamera();
    }
    if (keyPressed(LogicalKeyboardKey.delete)) {
      edit.delete();
    }
    if (keyPressed(LogicalKeyboardKey.keyR)) {
      edit.selected.value = edit.selected.value;
    }
    if (engine.mouseRightDown.value){
      setPlayModePlay();
    }
    if (_getKeyDirection() != null) {
       setPlayModePlay();
    }
    return;
  }

  // PLAY MODE

  if (sceneMetaDataMapEditable.value) {
    if (keyPressed(LogicalKeyboardKey.space)) {
      setPlayModeEdit();
      return;
    }
  }

  if (keyPressed(keys.speak)){
    messageBoxShow();
  }

  if (messageBoxVisible.value) return;

  if (engine.mouseLeftDown.value) {
    if (keyPressed(LogicalKeyboardKey.shiftLeft)){
      sendClientRequestAttack();
    } else {
      setCharacterActionPerform();
    }
    return;
  }

  final direction = _getKeyDirection();
  if (direction != null) {
    characterDirection = direction;
    if (!keyPressed(LogicalKeyboardKey.shiftLeft)){
      setCharacterActionRun();
    }
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

