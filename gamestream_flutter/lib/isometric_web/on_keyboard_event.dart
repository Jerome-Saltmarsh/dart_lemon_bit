
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/game_library.dart';
import 'package:gamestream_flutter/isometric/actions/action_game_dialog_show_quests.dart';
import 'package:gamestream_flutter/isometric/actions/action_toggle_inventory.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:lemon_engine/engine.dart';

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
    return EditState.paintTorch();
  if (key == PhysicalKeyboardKey.keyZ){
    return GameState.spawnParticleFirePurple(x: mouseGridX, y: mouseGridY, z: GameState.player.z);
  }

  if (GameState.playMode) {
    if (key == PhysicalKeyboardKey.keyG)
      return GameNetwork.sendClientRequestTeleport();
    if (key == PhysicalKeyboardKey.keyI)
      return actionToggleInventoryVisible();
    if (key == PhysicalKeyboardKey.keyT)
      return actionGameDialogShowQuests();
    if (key == PhysicalKeyboardKey.keyM)
      return GameState.actionGameDialogShowMap();
    return;
  }

  // EDIT MODE
  if (key == PhysicalKeyboardKey.keyF) return EditState.paint();
  if (key == PhysicalKeyboardKey.keyR) return EditState.selectPaintType();
  if (key == PhysicalKeyboardKey.keyG) {
    if (EditState.gameObjectSelected.value) {
      GameNetwork.sendGameObjectRequestMoveToMouse();
    } else {
      cameraSetPositionGrid(EditState.row, EditState.column, EditState.z);
    }
  }

  if (key == PhysicalKeyboardKey.digit1)
    return EditState.delete();
  if (key == PhysicalKeyboardKey.digit2)
    return EditState.paintGrass();
  if (key == PhysicalKeyboardKey.digit3)
    return EditState.paintWater();
  if (key == PhysicalKeyboardKey.digit4)
    return EditState.paintBricks();
  if (key == PhysicalKeyboardKey.arrowUp) {
    if (shiftLeftDown) {
      if (EditState.gameObjectSelected.value){
        return EditState.translate(x: 0, y: 0, z: 1);
      }
      EditState.cursorZIncrease();
    } else {
      if (EditState.gameObjectSelected.value){
        return EditState.translate(x: -1, y: -1, z: 0);
      }
      EditState.cursorRowDecrease();
    }
  }
  if (key == PhysicalKeyboardKey.arrowRight) {
    if (EditState.gameObjectSelected.value){
      return EditState.translate(x: 1, y: -1, z: 0);
    }
    EditState.cursorColumnDecrease();
  }
  if (key == PhysicalKeyboardKey.arrowDown) {
    if (shiftLeftDown) {
      if (EditState.gameObjectSelected.value){
        return EditState.translate(x: 0, y: 0, z: -1);
      }
      EditState.cursorZDecrease();
    } else {
      if (EditState.gameObjectSelected.value){
        return EditState.translate(x: 1, y: 1, z: 0);
      }
      EditState.cursorRowIncrease();
    }
  }
  if (key == PhysicalKeyboardKey.arrowLeft) {
    if (EditState.gameObjectSelected.value){
      return EditState.translate(x: -1, y: 1, z: 0);
    }
    EditState.cursorColumnIncrease();
  }
}

bool get shiftLeftDown => Engine.keyPressed(LogicalKeyboardKey.shiftLeft);