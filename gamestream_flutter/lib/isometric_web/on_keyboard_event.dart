
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/game_library.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/game_editor.dart';
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
    return GameEditor.paintTorch();
  if (key == PhysicalKeyboardKey.keyZ){
    return GameState.spawnParticleFirePurple(x: mouseGridX, y: mouseGridY, z: GameState.player.z);
  }

  if (GameState.playMode) {
    if (key == PhysicalKeyboardKey.keyG)
      return GameNetwork.sendClientRequestTeleport();
    if (key == PhysicalKeyboardKey.keyI)
      return GameState.actionToggleInventoryVisible();
    if (key == PhysicalKeyboardKey.keyT)
      return GameState.actionGameDialogShowQuests();
    if (key == PhysicalKeyboardKey.keyM)
      return GameState.actionGameDialogShowMap();
    return;
  }

  // EDIT MODE
  if (key == PhysicalKeyboardKey.keyF) return GameEditor.paint();
  if (key == PhysicalKeyboardKey.keyR) return GameEditor.selectPaintType();
  if (key == PhysicalKeyboardKey.keyG) {
    if (GameEditor.gameObjectSelected.value) {
      GameNetwork.sendGameObjectRequestMoveToMouse();
    } else {
      cameraSetPositionGrid(GameEditor.row, GameEditor.column, GameEditor.z);
    }
  }

  if (key == PhysicalKeyboardKey.digit1)
    return GameEditor.delete();
  if (key == PhysicalKeyboardKey.digit2)
    return GameEditor.paintGrass();
  if (key == PhysicalKeyboardKey.digit3)
    return GameEditor.paintWater();
  if (key == PhysicalKeyboardKey.digit4)
    return GameEditor.paintBricks();
  if (key == PhysicalKeyboardKey.arrowUp) {
    if (shiftLeftDown) {
      if (GameEditor.gameObjectSelected.value){
        return GameEditor.translate(x: 0, y: 0, z: 1);
      }
      GameEditor.cursorZIncrease();
    } else {
      if (GameEditor.gameObjectSelected.value){
        return GameEditor.translate(x: -1, y: -1, z: 0);
      }
      GameEditor.cursorRowDecrease();
    }
  }
  if (key == PhysicalKeyboardKey.arrowRight) {
    if (GameEditor.gameObjectSelected.value){
      return GameEditor.translate(x: 1, y: -1, z: 0);
    }
    GameEditor.cursorColumnDecrease();
  }
  if (key == PhysicalKeyboardKey.arrowDown) {
    if (shiftLeftDown) {
      if (GameEditor.gameObjectSelected.value){
        return GameEditor.translate(x: 0, y: 0, z: -1);
      }
      GameEditor.cursorZDecrease();
    } else {
      if (GameEditor.gameObjectSelected.value){
        return GameEditor.translate(x: 1, y: 1, z: 0);
      }
      GameEditor.cursorRowIncrease();
    }
  }
  if (key == PhysicalKeyboardKey.arrowLeft) {
    if (GameEditor.gameObjectSelected.value){
      return GameEditor.translate(x: -1, y: 1, z: 0);
    }
    GameEditor.cursorColumnIncrease();
  }
}

bool get shiftLeftDown => Engine.keyPressed(LogicalKeyboardKey.shiftLeft);