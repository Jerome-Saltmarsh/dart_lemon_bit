
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/actions/action_game_dialog_show_quests.dart';
import 'package:gamestream_flutter/isometric/actions/action_toggle_inventory.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
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
    return actionToggleEdit();

  if (key == PhysicalKeyboardKey.digit5)
    return edit.paintTorch();
  if (key == PhysicalKeyboardKey.keyZ){
    return spawnParticleFirePurple(x: mouseGridX, y: mouseGridY, z: player.z);
  }

  if (playMode) {
    if (key == PhysicalKeyboardKey.keyG)
      return sendClientRequestTeleport();
    if (key == PhysicalKeyboardKey.keyI)
      return actionToggleInventoryVisible();
    if (key == PhysicalKeyboardKey.keyT)
      return actionGameDialogShowQuests();
    if (key == PhysicalKeyboardKey.keyM)
      return actionGameDialogShowMap();
    return;
  }

  // EDIT MODE
  if (key == PhysicalKeyboardKey.keyF) return edit.paint();
  if (key == PhysicalKeyboardKey.keyR) return edit.selectPaintType();
  if (key == PhysicalKeyboardKey.keyG) {
    if (edit.gameObjectSelected.value) {
      sendGameObjectRequestMoveToMouse();
    } else {
      cameraSetPositionGrid(edit.row, edit.column, edit.z);
    }
  }

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
      edit.cursorZIncrease();
    } else {
      if (edit.gameObjectSelected.value){
        return edit.translate(x: -1, y: -1, z: 0);
      }
      edit.cursorRowIncrease();
    }
  }
  if (key == PhysicalKeyboardKey.arrowRight) {
    if (edit.gameObjectSelected.value){
      return edit.translate(x: 1, y: -1, z: 0);
    }
    edit.cursorColumnIncrease();
  }
  if (key == PhysicalKeyboardKey.arrowDown) {
    if (shiftLeftDown) {
      if (edit.gameObjectSelected.value){
        return edit.translate(x: 0, y: 0, z: -1);
      }
      edit.cursorZDecrease();
    } else {
      if (edit.gameObjectSelected.value){
        return edit.translate(x: 1, y: 1, z: 0);
      }
      edit.cursorRowDecrease();
    }
  }
  if (key == PhysicalKeyboardKey.arrowLeft) {
    if (edit.gameObjectSelected.value){
      return edit.translate(x: -1, y: 1, z: 0);
    }
    edit.cursorColumnDecrease();
  }
}

bool get shiftLeftDown => keyPressed(LogicalKeyboardKey.shiftLeft);