
import 'dart:math';

import 'package:bleed_common/Direction.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric_web/on_mouse_clicked_left.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

import 'isometric/utils/mouse.dart';
import 'library.dart';


class GameIO {
  // STATE
  static var touchPanning = false;
  static var touchscreenDirection = Direction.None;
  static var touchscreenRadian = 0.0;
  static var touchscreenRadianInput = 0.0;

  // GETTERS
  static final inputMode = Watch(InputMode.Keyboard);
  static bool get inputModeTouch => inputMode.value == InputMode.Touch;
  static bool get inputModeKeyboard => inputMode.value == InputMode.Keyboard;
  static bool get keyPressedSpace => Engine.keyPressed(LogicalKeyboardKey.space);

  static var joystickLeftX = 0.0;
  static var joystickLeftY = 0.0;
  static var joystickLeftDown = false;

  static void detectInputMode() =>
    inputMode.value = Engine.deviceIsComputer
        ? InputMode.Keyboard
        : InputMode.Touch;

  static void actionToggleInputMode() =>
    inputMode.value = inputModeKeyboard ? InputMode.Touch : InputMode.Keyboard;

  static void addListeners() {
      Engine.onPanStart = onPanStart;
      Engine.onPanUpdate = onPanUpdate;
      Engine.onPanEnd = onPanEnd;
      Engine.onTapDown = onTapDown;
      Engine.onLongPressDown = onLongPressDown;
      Engine.onSecondaryTapDown = onSecondaryTapDown;
      Engine.onKeyDown = onRawKeyDownEvent;
      Engine.onLeftClicked = onMouseClickedLeft;
      Engine.onPointerSignalEvent = onPointerSignalEvent;
      Engine.onKeyHeld = onKeyHeld;
      Engine.onKeyPressed = onKeyPressed;
  }

  static void onPointerSignalEvent(PointerSignalEvent event){
    // print("onPointerSignalEvent($event)");
  }

  static void removeListeners() {
      Engine.onPanStart = null;
      Engine.onPanStart = null;
      Engine.onTapDown = null;
      Engine.onLongPressDown = null;
      Engine.onSecondaryTapDown = null;
      Engine.onKeyDown = null;
      Engine.onKeyUp = null;
      Engine.onLeftClicked = null;
  }

  static void onSecondaryTapDown(TapDownDetails details){
     // print("onSecondaryTapDown()");
  }

  static void onLongPressDown(LongPressDownDetails details){
    // print("onLongPressDown()");
  }

  static void onPanStart(DragStartDetails details) {
     // print("onPanStart()");
  }

  static void onPanUpdate(DragUpdateDetails details) {
    // print("onPanUpdate()");
    final deltaDirection = details.delta.direction;
    final deltaDistance = details.delta.distance;
    // print(deltaDistance);
    touchscreenRadianInput = deltaDirection < 0 ? deltaDirection + Engine.PI_2 : deltaDirection;
    if (touchPanning) {
      final radianDiff = Engine.calculateRadianDifference(touchscreenRadian, touchscreenRadianInput);
      if (radianDiff.abs() < pi * 0.75) {
        touchscreenRadian += Engine.calculateRadianDifference(touchscreenRadian, touchscreenRadianInput) * deltaDistance * 0.05;
        if (touchscreenRadian < 0){
          touchscreenRadian += Engine.PI_2;
        } else {
          touchscreenRadian %= Engine.PI_2;
        }
      } else {
        if (deltaDistance > 0.2){
          touchscreenRadian = touchscreenRadianInput;
        }
      }
    } else {
      touchPanning = true;
      touchscreenRadian = touchscreenRadianInput;
    }
    touchscreenDirection = convertRadianToDirection(touchscreenRadian);
  }

  static void onPanEnd(DragEndDetails details){
    // print('onPanEnd()');
    touchscreenDirection = Direction.None;
    touchPanning = false;
  }

  static void onKeyHeld(RawKeyDownEvent key, int duration) {
     // print('onKeyHeld(key: ${key.logicalKey.debugName}, duration: $duration)');
  }

  static void onKeyPressed(RawKeyDownEvent event) {
     if (event.logicalKey == LogicalKeyboardKey.keyX) {
       actionToggleInputMode();
     }
  }

  static int convertRadianToDirection(double radian) {
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 0)) return Direction.South_East;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 1)) return Direction.South;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 2)) return Direction.South_West;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 3)) return Direction.West;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 4)) return Direction.North_West;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 5)) return Direction.North;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 6)) return Direction.North_East;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 7)) return Direction.East;
     return Direction.East;
  }

  static void onTapDown(TapDownDetails details) {
    // print('onTapDown()');
  }

  static int getDirection() {
    final keyboardDirection = getDirectionKeyboard();
    if (keyboardDirection != Direction.None) return keyboardDirection;
    return inputModeKeyboard ? keyboardDirection : touchscreenDirection;
  }

  static int getDirectionKeyboard() {

    if (Engine.keyPressed(LogicalKeyboardKey.keyW)) {
      if (Engine.keyPressed(LogicalKeyboardKey.keyD)) {
        return Direction.East;
      }
      if (Engine.keyPressed(LogicalKeyboardKey.keyA)) {
        return Direction.North;
      }
      return Direction.North_East;
    }

    if (Engine.keyPressed(LogicalKeyboardKey.keyS)) {
      if (Engine.keyPressed(LogicalKeyboardKey.keyD)) {
        return Direction.South;
      }
      if (Engine.keyPressed(LogicalKeyboardKey.keyA)) {
        return Direction.West;
      }
      return Direction.South_West;
    }
    if (Engine.keyPressed(LogicalKeyboardKey.keyA)) {
      return Direction.North_West;
    }
    if (Engine.keyPressed(LogicalKeyboardKey.keyD)) {
      return Direction.South_East;
    }
    return Direction.None;
  }

  static bool getActionPrimary(){
    if (GameState.editMode) return false;
    if (inputModeKeyboard) {
      return Engine.watchMouseLeftDown.value;
    }
    return false;
  }

  static bool getActionSecondary(){
    if (GameState.editMode) return false;
    return false;
  }

  static bool getActionTertiary(){
    if (GameState.editMode) return false;
    return false;
  }

  static void onRawKeyDownEvent(RawKeyDownEvent event){
    final key = event.physicalKey;

    if (key == PhysicalKeyboardKey.tab)
      return GameActions.actionToggleEdit();

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
      if (Engine.keyPressedShiftLeft) {
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
      if (Engine.keyPressedShiftLeft) {
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

  static void onMouseClickedLeft(){
    if (GameState.edit.value) {
      onMouseClickedEditMode();
    }
  }
}