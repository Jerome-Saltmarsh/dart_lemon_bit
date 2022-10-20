
import 'package:bleed_common/Direction.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/engine.dart';

import 'game.dart';

class GameIO {
  // STATE
  static var touchscreenDirection = Direction.None;

  // GETTERS
  static bool get modeTouchscreen => Engine.deviceIsPhone;
  static bool get modeKeyboard => Engine.deviceIsComputer;
  static bool get keyPressedSpace => Engine.keyPressed(LogicalKeyboardKey.space);

  static void initGameListeners() {
      Engine.onPanStart = onPanStart;
      Engine.onPanUpdate = onPanUpdate;
      Engine.onPanEnd = onPanEnd;
      Engine.onTapDown = onTapDown;
      Engine.onLongPressDown = onLongPressDown;
      Engine.onSecondaryTapDown = onSecondaryTapDown;
  }

  static void onSecondaryTapDown(TapDownDetails details){
     print("onSecondaryTapDown()");
  }

  static void onLongPressDown(LongPressDownDetails details){
    print("onLongPressDown()");
  }

  static void onPanStart(DragStartDetails details) {
     print("onPanStart()");
  }

  static void onPanUpdate(DragUpdateDetails details) {
    final detailsDirection = details.delta.direction;
    final radian = detailsDirection < 0 ? detailsDirection + Engine.PI_2 : detailsDirection;
    touchscreenDirection = convertRadianToDirection(radian);
  }

  static int convertRadianToDirection(double radian){
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

  static void onPanEnd(DragEndDetails details){
    touchscreenDirection = Direction.None;
  }

  static void onTapDown(TapDownDetails details){
    print('onTapDown()');
  }

  static int getDirection() {
    final keyDirection = getKeyDirection();
    if (keyDirection != Direction.None){
      return keyDirection;
    }
    if (Engine.deviceIsComputer){
      return Direction.None;
    }
    return touchscreenDirection;
  }

  static int getKeyDirection() {
    final keysPressed = Engine.keyboard.keysPressed;

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

  static bool getActionPrimary(){
    if (Game.editMode) return false;
    if (modeKeyboard) {
      return Engine.watchMouseLeftDown.value;
    }
    return false;
  }

  static bool getActionSecondary(){
    if (Game.editMode) return false;
    return false;
  }

  static bool getActionTertiary(){
    if (Game.editMode) return false;
    return false;
  }
}