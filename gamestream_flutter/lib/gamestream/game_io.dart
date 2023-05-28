
import 'package:flutter/gestures.dart';

import '../library.dart';
import '../touch_controller.dart';


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

  double get mouseGridX => GameConvert.convertWorldToGridX(engine.mouseWorldX, engine.mouseWorldY) + GamePlayer.position.z;
  double get mouseGridY => GameConvert.convertWorldToGridY(engine.mouseWorldX, engine.mouseWorldY) + GamePlayer.position.z;
  double get mouseGridZ => GamePlayer.position.z;

  void recenterCursor(){
    touchCursorWorldX = GamePlayer.renderX;
    touchCursorWorldY = GamePlayer.renderY;
  }

  void detectInputMode() =>
    inputMode.value = engine.deviceIsComputer
        ? InputMode.Keyboard
        : InputMode.Touch;

  void actionToggleInputMode() =>
    inputMode.value = inputModeKeyboard ? InputMode.Touch : InputMode.Keyboard;

  void addListeners() {
      engine.onTapDown = onTapDown;
      engine.onTap = onTap;
      engine.onLongPressDown = onLongPressDown;
      engine.onSecondaryTapDown = onSecondaryTapDown;
      engine.onLeftClicked = onMouseClickedLeft;
      engine.onRightClicked = onMouseClickedRight;
      engine.onPointerSignalEvent = onPointerSignalEvent;
      engine.onKeyPressed = ClientEvents.onKeyPressed;
  }

  void onPointerSignalEvent(PointerSignalEvent event){
    // print("onPointerSignalEvent($event)");
  }

  void removeListeners() {
      engine.onTapDown = null;
      engine.onLongPressDown = null;
      engine.onSecondaryTapDown = null;
      engine.onKeyDown = null;
      engine.onKeyUp = null;
      engine.onLeftClicked = null;
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
    touchCursorWorldX = engine.screenToWorldX(_touchCursorTapX);
    touchCursorWorldY = engine.screenToWorldY(_touchCursorTapY);

    if (inputModeKeyboard && engine.keyPressedShiftLeft){
      gamestream.games.isometric.actions.attackAuto();
    } else {
      gamestream.games.isometric.actions.setTarget();
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

    if (engine.watchMouseLeftDown.value) {
      hex = hex | ByteHex.Hex_16;
    }

    if (TouchController.attack) {
      TouchController.attack = false;
      hex = hex | ByteHex.Hex_16;
    }

    if (inputModeKeyboard) {

      hex = hex | ByteHex.Hex_64;

      if (engine.mouseRightDown.value) {
        hex = hex | ByteHex.Hex_32;
      }
      if (engine.keyPressedSpace){
        hex = hex | ByteHex.Hex_128;
      }
    }

    return hex;
  }

  double getCursorWorldX() {
    // if (inputModeTouch){
    //   return touchCursorWorldX;
    // } else {
    //   return engine.mouseWorldX;
    // }

    return engine.mouseWorldX;
  }
  double getCursorWorldY() {
    // if (inputModeTouch){
    //   return touchCursorWorldY;
    // } else {
    //   return engine.mouseWorldY;
    // }
    return engine.mouseWorldY;
  }

  double getCursorScreenX() {
     if (inputModeTouch){
       return engine.worldToScreenX(touchCursorWorldX);
     } else {
       return engine.mousePositionX;
     }
  }

  double getCursorScreenY() {
    if (inputModeTouch) {
      return engine.worldToScreenY(touchCursorWorldY);
    } else {
      return engine.mousePositionY;
    }
  }

  int getDirection() {
    return inputModeKeyboard ? getInputDirectionKeyboard() : getDirectionTouchScreen();
  }

  int getDirectionTouchScreen() {
    return TouchController.getDirection();
  }

  int getInputDirectionKeyboard() {

    if (engine.keyPressed(KeyCode.W)) {
      if (engine.keyPressed(KeyCode.D)) {
        return InputDirection.Up_Right;
      }
      if (engine.keyPressed(KeyCode.A)) {
        return InputDirection.Up_Left;
      }
      return InputDirection.Up;
    }

    if (engine.keyPressed(KeyCode.S)) {
      if (engine.keyPressed(KeyCode.D)) {
        return InputDirection.Down_Right;
      }
      if (engine.keyPressed(KeyCode.A)) {
        return InputDirection.Down_Left;
      }
      return InputDirection.Down;
    }
    if (engine.keyPressed(KeyCode.A)) {
      return InputDirection.Left;
    }
    if (engine.keyPressed(KeyCode.D)) {
      return InputDirection.Right;
    }
    return InputDirection.None;
  }


  void setCursorAction(int cursorAction) {
    gamestream.io.touchscreenCursorAction = CursorAction.None;
  }

  bool getActionSecondary(){
    if (gamestream.games.isometric.clientState.editMode) return false;
    return false;
  }

  bool getActionTertiary(){
    if (gamestream.games.isometric.clientState.editMode) return false;
    return false;
  }

  void onMouseClickedLeft(){
    if (gamestream.games.isometric.clientState2.edit.value) {
      onMouseClickedEditMode();
    }
  }

  void onMouseClickedRight(){
    gamestream.games.isometric.actions.attackAuto();
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
    if (gamestream.games.isometric.clientState2.edit.value) {
      return readPlayerInputEdit();
    }
  }

  void readPlayerInputEdit() {
    if (engine.keyPressedSpace) {
      engine.panCamera();
    }
    if (engine.keyPressed(KeyCode.Delete)) {
      GameEditor.delete();
    }
    if (gamestream.io.getInputDirectionKeyboard() != Direction.None) {
      gamestream.games.isometric.actions.actionSetModePlay();
    }
    return;
  }

  void mouseRaycast(Function(int z, int row, int column) callback){
    var z = gamestream.games.isometric.nodes.totalZ - 1;
    final mouseWorldX = engine.mouseWorldX;
    final mouseWorldY = engine.mouseWorldY;
    while (z >= 0){
      final row = GameConvert.convertWorldToRow(mouseWorldX, mouseWorldY, z * Node_Height);
      final column = GameConvert.convertWorldToColumn(mouseWorldX, mouseWorldY, z * Node_Height);
      if (row < 0) break;
      if (column < 0) break;
      if (row >= gamestream.games.isometric.nodes.totalRows) break;
      if (column >= gamestream.games.isometric.nodes.totalColumns) break;
      if (z >= gamestream.games.isometric.nodes.totalZ) break;
      final index = gamestream.games.isometric.clientState.getNodeIndexZRC(z, row, column);
      if (NodeType.isRainOrEmpty(gamestream.games.isometric.nodes.nodeTypes[index])) {
        z--;
        continue;
      }
      // if (gamestream.games.isometric.nodes.nodeVisible[index] == Visibility.Invisible) {
      //   z--;
      //   continue;
      // }
      callback(z, row, column);
      return;
    }
  }
}