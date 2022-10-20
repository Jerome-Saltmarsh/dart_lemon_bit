
import 'package:bleed_common/Direction.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/engine.dart';

import 'game.dart';

class GameIO {


  static bool get keyPressedSpace => Engine.keyPressed(LogicalKeyboardKey.space);

  static void initGameListeners(){
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
    print("onPanUpdate()");
    // GameNetwork.
  }

  static void onPanEnd(DragEndDetails details){
    print("onPanEnd()");
  }

  static void onTapDown(TapDownDetails details){
    print('onTapDown()');
  }

  static int getDirection(){
    if (Engine.deviceIsComputer){
      return getKeyDirection();
    }
    return Direction.None;
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
    return Engine.watchMouseLeftDown.value;
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