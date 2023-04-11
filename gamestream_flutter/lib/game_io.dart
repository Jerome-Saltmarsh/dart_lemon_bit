
import 'package:flutter/gestures.dart';

import 'library.dart';


class GameIO {
  static var _touchCursorTapX = 0.0;
  static var _touchCursorTapY = 0.0;
  static var touchCursorWorldX = 100.0;
  static var touchCursorWorldY = 100.0;
  static bool _panning = false;

  static var previousVelocityX = 0.0;
  static var previousVelocityY = 0.0;
  static var previousVelocityX2 = 0.0;
  static var previousVelocityY2 = 0.0;

  static var touchPanning = false;
  static var touchscreenDirectionMove = Direction.None;
  static var touchscreenCursorAction = CursorAction.None;
  static var touchscreenRadianInput = 0.0;
  static var touchscreenRadianMove = 0.0;
  static var touchscreenRadianPerform = 0.0;
  static var performActionPrimary = false;

  static final inputMode = Watch(InputMode.Keyboard, onChanged: GameEvents.onChangedInputMode);
  static bool get inputModeTouch => inputMode.value == InputMode.Touch;
  static bool get inputModeKeyboard => inputMode.value == InputMode.Keyboard;

  static var joystickLeftX = 0.0;
  static var joystickLeftY = 0.0;
  static var joystickLeftDown = false;
  var touchscreenAimX = 0.0;
  var touchscreenAimY = 0.0;
  static var panDistance = Watch(0.0);
  static var panDirection = Watch(0.0);

  static double get mouseGridX => GameConvert.convertWorldToGridX(Engine.mouseWorldX, Engine.mouseWorldY) + GamePlayer.position.z;
  static double get mouseGridY => GameConvert.convertWorldToGridY(Engine.mouseWorldX, Engine.mouseWorldY) + GamePlayer.position.z;
  static double get mouseGridZ => GamePlayer.position.z;

  static void recenterCursor(){
    touchCursorWorldX = GamePlayer.renderX;
    touchCursorWorldY = GamePlayer.renderY;
  }

  static void detectInputMode() =>
    inputMode.value = Engine.deviceIsComputer
        ? InputMode.Keyboard
        : InputMode.Touch;

  static void actionToggleInputMode() =>
    inputMode.value = inputModeKeyboard ? InputMode.Touch : InputMode.Keyboard;

  static void addListeners() {
      Engine.onTapDown = onTapDown;
      Engine.onTap = onTap;
      Engine.onLongPressDown = onLongPressDown;
      Engine.onSecondaryTapDown = onSecondaryTapDown;
      Engine.onLeftClicked = onMouseClickedLeft;
      Engine.onRightClicked = onMouseClickedRight;
      Engine.onPointerSignalEvent = onPointerSignalEvent;
      Engine.onKeyPressed = ClientEvents.onKeyPressed;
  }

  static void onPointerSignalEvent(PointerSignalEvent event){
    // print("onPointerSignalEvent($event)");
  }

  static void removeListeners() {
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

  static int convertRadianToDirection(double radian) {
    radian = radian < 0 ? radian + Engine.PI_2 : radian % Engine.PI_2;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 0)) return Direction.South_East;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 1)) return Direction.South;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 2)) return Direction.South_West;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 3)) return Direction.West;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 4)) return Direction.North_West;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 5)) return Direction.North;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 6)) return Direction.North_East;
     if (radian < Engine.PI_Eight + (Engine.PI_Quarter * 7)) return Direction.East;
     return Direction.South_East;
  }

  static void onTap(){
    // print("onTap()");
    touchCursorWorldX = Engine.screenToWorldX(_touchCursorTapX);
    touchCursorWorldY = Engine.screenToWorldY(_touchCursorTapY);

    if (inputModeKeyboard && Engine.keyPressedShiftLeft){
      GameActions.attackAuto();
    } else {
      GameActions.setTarget();
    }
  }

  static void onTapDown(TapDownDetails details) {
    // print("onTapDown()");
    _touchCursorTapX = details.globalPosition.dx;
    _touchCursorTapY = details.globalPosition.dy;
  }

  static double get touchMouseWorldZ => GamePlayer.position.z;

  /// compresses keyboard and mouse inputs into a single byte to send to the server
  static int getInputAsByte(){

    var hex = GameIO.getDirection();

    if (Engine.watchMouseLeftDown.value) {
      hex = hex | ByteHex.Hex_16;
    }

    if (GameIO.inputModeKeyboard) {

      hex = hex | ByteHex.Hex_64;

      if (Engine.mouseRightDown.value) {
        hex = hex | ByteHex.Hex_32;
      }
      if (Engine.keyPressedSpace){
        hex = hex | ByteHex.Hex_128;
      }
    }

    return hex;
  }

  static double getCursorWorldX() {
    // if (inputModeTouch){
    //   return touchCursorWorldX;
    // } else {
    //   return Engine.mouseWorldX;
    // }

    return Engine.mouseWorldX;
  }
  static double getCursorWorldY() {
    // if (inputModeTouch){
    //   return touchCursorWorldY;
    // } else {
    //   return Engine.mouseWorldY;
    // }
    return Engine.mouseWorldY;
  }

  static double getCursorScreenX() {
     if (inputModeTouch){
       return Engine.worldToScreenX(touchCursorWorldX);
     } else {
       return Engine.mousePosition.x;
     }
  }

  static double getCursorScreenY() {
    if (inputModeTouch) {
      return Engine.worldToScreenY(touchCursorWorldY);
    } else {
      return Engine.mousePosition.y;
    }
  }

  static int getDirection() {
    final keyboardDirection = getDirectionKeyboard();
    if (keyboardDirection != Direction.None) return keyboardDirection;
    return inputModeKeyboard ? keyboardDirection : touchscreenDirectionMove;
  }

  static int getDirectionKeyboard() {

    if (Engine.keyPressed(KeyCode.W)) {
      if (Engine.keyPressed(KeyCode.D)) {
        return Direction.East;
      }
      if (Engine.keyPressed(KeyCode.A)) {
        return Direction.North;
      }
      return Direction.North_East;
    }

    if (Engine.keyPressed(KeyCode.S)) {
      if (Engine.keyPressed(KeyCode.D)) {
        return Direction.South;
      }
      if (Engine.keyPressed(KeyCode.A)) {
        return Direction.West;
      }
      return Direction.South_West;
    }
    if (Engine.keyPressed(KeyCode.A)) {
      return Direction.North_West;
    }
    if (Engine.keyPressed(KeyCode.D)) {
      return Direction.South_East;
    }
    return Direction.None;
  }


  static void setCursorAction(int cursorAction) {
    GameIO.touchscreenCursorAction = CursorAction.None;
  }

  static bool getActionSecondary(){
    if (GameState.editMode) return false;
    return false;
  }

  static bool getActionTertiary(){
    if (GameState.editMode) return false;
    return false;
  }

  static void onMouseClickedLeft(){
    if (ClientState.edit.value) {
      onMouseClickedEditMode();
    }
  }

  static void onMouseClickedRight(){
    GameActions.attackAuto();
  }

  static void onMouseClickedEditMode(){
    switch (GameEditor.editTab.value) {
      case EditTab.File:
        GameEditor.setTabGrid();
        GameEditor.selectMouseBlock();
        break;
      case EditTab.Grid:
        GameEditor.selectMouseBlock();
        GameEditor.actionRecenterCamera();
        break;
      case EditTab.Objects:
        GameEditor.selectMouseGameObject();
        break;
    }
  }

  static void readPlayerInput() {
    if (ClientState.edit.value) {
      return readPlayerInputEdit();
    }
  }

  static void readPlayerInputEdit() {
    if (Engine.keyPressedSpace) {
      Engine.panCamera();
    }
    if (Engine.keyPressed(KeyCode.Delete)) {
      GameEditor.delete();
    }
    if (GameIO.getDirectionKeyboard() != Direction.None) {
      GameActions.actionSetModePlay();
    }
    return;
  }

  static void mouseRaycast(Function(int z, int row, int column) callback){
    var z = GameNodes.totalZ - 1;
    final mouseWorldX = Engine.mouseWorldX;
    final mouseWorldY = Engine.mouseWorldY;
    while (z >= 0){
      final row = GameConvert.convertWorldToRow(mouseWorldX, mouseWorldY, z * Node_Height);
      final column = GameConvert.convertWorldToColumn(mouseWorldX, mouseWorldY, z * Node_Height);
      if (row < 0) break;
      if (column < 0) break;
      if (row >= GameNodes.totalRows) break;
      if (column >= GameNodes.totalColumns) break;
      if (z >= GameNodes.totalZ) break;
      final index = GameState.getNodeIndexZRC(z, row, column);
      if (NodeType.isRainOrEmpty(GameNodes.nodeTypes[index])) {
        z--;
        continue;
      }
      // if (GameNodes.nodeVisible[index] == Visibility.Invisible) {
      //   z--;
      //   continue;
      // }
      callback(z, row, column);
      return;
    }
  }
}