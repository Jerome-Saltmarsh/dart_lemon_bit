
import 'package:flutter/gestures.dart';

import 'engine/instances.dart';
import 'library.dart';
import 'touch_controller.dart';


class GameIO {
  var _touchCursorTapX = 0.0;
  var _touchCursorTapY = 0.0;
  var touchCursorWorldX = 100.0;
  var touchCursorWorldY = 100.0;

  var previousVelocityX = 0.0;
  var previousVelocityY = 0.0;
  var previousVelocityX2 = 0.0;
  var previousVelocityY2 = 0.0;

  var touchPanning = false;
  var touchscreenDirectionMove = Direction.None;
  var touchscreenCursorAction = CursorAction.None;
  var touchscreenRadianInput = 0.0;
  var touchscreenRadianMove = 0.0;
  var touchscreenRadianPerform = 0.0;
  var performActionPrimary = false;

  final inputMode = Watch(InputMode.Keyboard, onChanged: GameEvents.onChangedInputMode);
  bool get inputModeTouch => inputMode.value == InputMode.Touch;
  bool get inputModeKeyboard => inputMode.value == InputMode.Keyboard;

  var joystickLeftX = 0.0;
  var joystickLeftY = 0.0;
  var joystickLeftDown = false;
  var touchscreenAimX = 0.0;
  var touchscreenAimY = 0.0;
  var panDistance = Watch(0.0);
  var panDirection = Watch(0.0);

  double get mouseGridX => GameConvert.convertWorldToGridX(Engine.mouseWorldX, Engine.mouseWorldY) + GamePlayer.position.z;
  double get mouseGridY => GameConvert.convertWorldToGridY(Engine.mouseWorldX, Engine.mouseWorldY) + GamePlayer.position.z;
  double get mouseGridZ => GamePlayer.position.z;

  void recenterCursor(){
    touchCursorWorldX = GamePlayer.renderX;
    touchCursorWorldY = GamePlayer.renderY;
  }

  void detectInputMode() =>
    inputMode.value = Engine.deviceIsComputer
        ? InputMode.Keyboard
        : InputMode.Touch;

  void actionToggleInputMode() =>
    inputMode.value = inputModeKeyboard ? InputMode.Touch : InputMode.Keyboard;

  void addListeners() {
      Engine.onTapDown = onTapDown;
      Engine.onTap = onTap;
      Engine.onLongPressDown = onLongPressDown;
      Engine.onSecondaryTapDown = onSecondaryTapDown;
      Engine.onLeftClicked = onMouseClickedLeft;
      Engine.onRightClicked = onMouseClickedRight;
      Engine.onPointerSignalEvent = onPointerSignalEvent;
      Engine.onKeyPressed = ClientEvents.onKeyPressed;
  }

  void onPointerSignalEvent(PointerSignalEvent event){
    // print("onPointerSignalEvent($event)");
  }

  void removeListeners() {
      Engine.onTapDown = null;
      Engine.onLongPressDown = null;
      Engine.onSecondaryTapDown = null;
      Engine.onKeyDown = null;
      Engine.onKeyUp = null;
      Engine.onLeftClicked = null;
  }

  void onSecondaryTapDown(TapDownDetails details){
     // print("onSecondaryTapDown()");
  }

  void onLongPressDown(LongPressDownDetails details){
    // print("onLongPressDown()");
  }

  int convertRadianToDirection(double radian) {
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

  void onTap(){
    // print("onTap()");
    touchCursorWorldX = Engine.screenToWorldX(_touchCursorTapX);
    touchCursorWorldY = Engine.screenToWorldY(_touchCursorTapY);

    if (inputModeKeyboard && Engine.keyPressedShiftLeft){
      gamestream.actions.attackAuto();
    } else {
      gamestream.actions.setTarget();
    }
  }

  void onTapDown(TapDownDetails details) {
    // print("onTapDown()");
    _touchCursorTapX = details.globalPosition.dx;
    _touchCursorTapY = details.globalPosition.dy;
  }

  double get touchMouseWorldZ => GamePlayer.position.z;

  /// compresses keyboard and mouse inputs into a single byte to send to the server
  int getInputAsByte(){

    var hex = getDirection();

    if (Engine.watchMouseLeftDown.value) {
      hex = hex | ByteHex.Hex_16;
    }

    if (TouchController.attack) {
      TouchController.attack = false;
      hex = hex | ByteHex.Hex_16;
    }

    if (inputModeKeyboard) {

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

  double getCursorWorldX() {
    // if (inputModeTouch){
    //   return touchCursorWorldX;
    // } else {
    //   return Engine.mouseWorldX;
    // }

    return Engine.mouseWorldX;
  }
  double getCursorWorldY() {
    // if (inputModeTouch){
    //   return touchCursorWorldY;
    // } else {
    //   return Engine.mouseWorldY;
    // }
    return Engine.mouseWorldY;
  }

  double getCursorScreenX() {
     if (inputModeTouch){
       return Engine.worldToScreenX(touchCursorWorldX);
     } else {
       return Engine.mousePositionX;
     }
  }

  double getCursorScreenY() {
    if (inputModeTouch) {
      return Engine.worldToScreenY(touchCursorWorldY);
    } else {
      return Engine.mousePositionY;
    }
  }

  int getDirection() {
    return inputModeKeyboard ? getInputDirectionKeyboard() : getDirectionTouchScreen();
  }

  int getDirectionTouchScreen() {
    return TouchController.getDirection();
  }

  int getInputDirectionKeyboard() {

    if (Engine.keyPressed(KeyCode.W)) {
      if (Engine.keyPressed(KeyCode.D)) {
        return InputDirection.Up_Right;
      }
      if (Engine.keyPressed(KeyCode.A)) {
        return InputDirection.Up_Left;
      }
      return InputDirection.Up;
    }

    if (Engine.keyPressed(KeyCode.S)) {
      if (Engine.keyPressed(KeyCode.D)) {
        return InputDirection.Down_Right;
      }
      if (Engine.keyPressed(KeyCode.A)) {
        return InputDirection.Down_Left;
      }
      return InputDirection.Down;
    }
    if (Engine.keyPressed(KeyCode.A)) {
      return InputDirection.Left;
    }
    if (Engine.keyPressed(KeyCode.D)) {
      return InputDirection.Right;
    }
    return InputDirection.None;
  }


  void setCursorAction(int cursorAction) {
    gamestream.io.touchscreenCursorAction = CursorAction.None;
  }

  bool getActionSecondary(){
    if (GameState.editMode) return false;
    return false;
  }

  bool getActionTertiary(){
    if (GameState.editMode) return false;
    return false;
  }

  void onMouseClickedLeft(){
    if (ClientState.edit.value) {
      onMouseClickedEditMode();
    }
  }

  void onMouseClickedRight(){
    gamestream.actions.attackAuto();
  }

  void onMouseClickedEditMode(){
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

  void readPlayerInput() {
    if (ClientState.edit.value) {
      return readPlayerInputEdit();
    }
  }

  void readPlayerInputEdit() {
    if (Engine.keyPressedSpace) {
      Engine.panCamera();
    }
    if (Engine.keyPressed(KeyCode.Delete)) {
      GameEditor.delete();
    }
    if (gamestream.io.getInputDirectionKeyboard() != Direction.None) {
      gamestream.actions.actionSetModePlay();
    }
    return;
  }

  void mouseRaycast(Function(int z, int row, int column) callback){
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