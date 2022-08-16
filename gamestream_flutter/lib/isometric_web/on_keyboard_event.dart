
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/actions/action_game_dialog_show_quests.dart';
import 'package:gamestream_flutter/isometric/actions/action_toggle_inventory.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/editor/editor.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:lemon_engine/engine.dart';

import '../isometric/actions/action_game_dialog_show_map.dart';

void onKeyboardEvent(RawKeyEvent event){
  if (event is RawKeyDownEvent){
    return onRawKeyDownEvent(event);
  }
  if (event is RawKeyUpEvent){
    return;
  }
}

void onRawKeyDownEvent(RawKeyDownEvent event){
  final key = event.physicalKey;

  if (key == PhysicalKeyboardKey.tab)
    return actionPlayModeToggle();

  if (key == PhysicalKeyboardKey.digit5)
    return edit.paintTorch();
  if (key == PhysicalKeyboardKey.digit6)
    return edit.paintTree();
  if (key == PhysicalKeyboardKey.digit7)
    return edit.paintLongGrass();
  if (key == PhysicalKeyboardKey.keyU)
    return editor.actions.raise();
  if (key == PhysicalKeyboardKey.keyX)
    return edit.paintMouse();

  if (modeIsPlay) {
    if (key == PhysicalKeyboardKey.keyG)
      return sendClientRequestTeleport();
    if (key == PhysicalKeyboardKey.keyI)
      return actionToggleInventoryVisible();
    if (key == PhysicalKeyboardKey.keyT)
      return actionGameDialogShowQuests();
    if (key == PhysicalKeyboardKey.keyM)
      return actionGameDialogShowMap();
    if (key == PhysicalKeyboardKey.keyJ)
      return sendClientRequestAttackBasic();
  }

  // EDIT MODE
  if (key == PhysicalKeyboardKey.keyF) return edit.paint();
  if (key == PhysicalKeyboardKey.keyR) return edit.selectPaintType();
  if (key == PhysicalKeyboardKey.keyG) {
    cameraSetPositionGrid(edit.row.value, edit.column.value, edit.z.value);
  }
  if (key == PhysicalKeyboardKey.keyY)
    return editor.actions.elevate();
  if (key == PhysicalKeyboardKey.keyH)
    return editor.actions.lower();
  if (key == PhysicalKeyboardKey.keyC)
    return editor.actions.clear();
  if (key == PhysicalKeyboardKey.keyE)
    return edit.fill();
  if (key == PhysicalKeyboardKey.digit1)
    return edit.delete();
  if (key == PhysicalKeyboardKey.digit2)
    return edit.paintGrass();
  if (key == PhysicalKeyboardKey.digit3)
    return edit.paintWater();
  if (key == PhysicalKeyboardKey.digit4)
    return edit.paintBricks();
  if (key == PhysicalKeyboardKey.arrowUp) {
    if (shiftLeftDown) {
      if (edit.gameObjectSelected.value){
        return edit.translate(x: 0, y: 0, z: 1);
      }
      edit.z.value++;
    } else {
      if (edit.gameObjectSelected.value){
        return edit.translate(x: -1, y: -1, z: 0);
      }
      edit.row.value--;
    }
  }
  if (key == PhysicalKeyboardKey.arrowRight) {
    if (edit.gameObjectSelected.value){
      return edit.translate(x: 1, y: -1, z: 0);
    }
    edit.column.value--;
  }
  if (key == PhysicalKeyboardKey.arrowDown) {
    if (shiftLeftDown) {
      if (edit.gameObjectSelected.value){
        return edit.translate(x: 0, y: 0, z: -1);
      }
      edit.z.value--;
    } else {
      if (edit.gameObjectSelected.value){
        return edit.translate(x: 1, y: 1, z: 0);
      }
      edit.row.value++;
    }
  }
  if (key == PhysicalKeyboardKey.arrowLeft) {
    if (edit.gameObjectSelected.value){
      return edit.translate(x: -1, y: 1, z: 0);
    }
    edit.column.value++;
  }
}

bool get shiftLeftDown => keyPressed(LogicalKeyboardKey.shiftLeft);