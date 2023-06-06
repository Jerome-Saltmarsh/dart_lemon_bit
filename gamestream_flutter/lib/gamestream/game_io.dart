
import 'dart:ui';

import 'package:flutter/gestures.dart';

import '../library.dart';
import 'games/isometric/game_isometric.dart';


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

  final touchController = TouchController();

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

  double get mouseGridX => GameIsometric.convertWorldToGridX(engine.mouseWorldX, engine.mouseWorldY) + gamestream.isometric.player.position.z;
  double get mouseGridY => GameIsometric.convertWorldToGridY(engine.mouseWorldX, engine.mouseWorldY) + gamestream.isometric.player.position.z;
  double get mouseGridZ => gamestream.isometric.player.position.z;

  void recenterCursor(){
    touchCursorWorldX = gamestream.isometric.player.renderX;
    touchCursorWorldY = gamestream.isometric.player.renderY;
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
      gamestream.isometric.actions.attackAuto();
    } else {
      gamestream.isometric.actions.setTarget();
    }
  }

  void onTapDown(TapDownDetails details) {
    // print("onTapDown()");
    _touchCursorTapX = details.globalPosition.dx;
    _touchCursorTapY = details.globalPosition.dy;
  }

  double get touchMouseWorldZ => gamestream.isometric.player.position.z;

  /// compresses keyboard and mouse inputs into a single byte to send to the server
  int getInputAsByte(){

    var hex = getDirection();

    if (engine.watchMouseLeftDown.value) {
      hex = hex | ByteHex.Hex_16;
    }

    if (touchController.attack) {
      touchController.attack = false;
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
    return touchController.getDirection();
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
    if (gamestream.isometric.clientState.editMode) return false;
    return false;
  }

  bool getActionTertiary(){
    if (gamestream.isometric.clientState.editMode) return false;
    return false;
  }

  void onMouseClickedLeft(){
    if (gamestream.isometric.clientState.edit.value) {
      onMouseClickedEditMode();
    }
  }

  void onMouseClickedRight(){
    gamestream.isometric.actions.attackAuto();
  }

  void onMouseClickedEditMode(){
    switch (gamestream.isometric.editor.editTab.value) {
      case EditTab.File:
        gamestream.isometric.editor.setTabGrid();
        gamestream.isometric.editor.selectMouseBlock();
        break;
      case EditTab.Grid:
        gamestream.isometric.editor.selectMouseBlock();
        gamestream.isometric.editor.actionRecenterCamera();
        break;
      case EditTab.Objects:
        gamestream.isometric.editor.selectMouseGameObject();
        break;
    }
  }

  void readPlayerInput() {
    if (gamestream.isometric.clientState.edit.value) {
      return readPlayerInputEdit();
    }
  }

  void readPlayerInputEdit() {
    if (engine.keyPressedSpace) {
      engine.panCamera();
    }
    if (engine.keyPressed(KeyCode.Delete)) {
      gamestream.isometric.editor.delete();
    }
    if (gamestream.io.getInputDirectionKeyboard() != Direction.None) {
      gamestream.isometric.actions.actionSetModePlay();
    }
    return;
  }

  void mouseRaycast(Function(int z, int row, int column) callback){
    var z = gamestream.isometric.nodes.totalZ - 1;
    final mouseWorldX = engine.mouseWorldX;
    final mouseWorldY = engine.mouseWorldY;
    while (z >= 0){
      final row = GameIsometric.convertWorldToRow(mouseWorldX, mouseWorldY, z * Node_Height);
      final column = GameIsometric.convertWorldToColumn(mouseWorldX, mouseWorldY, z * Node_Height);
      if (row < 0) break;
      if (column < 0) break;
      if (row >= gamestream.isometric.nodes.totalRows) break;
      if (column >= gamestream.isometric.nodes.totalColumns) break;
      if (z >= gamestream.isometric.nodes.totalZ) break;
      final index = gamestream.isometric.clientState.getNodeIndexZRC(z, row, column);
      if (NodeType.isRainOrEmpty(gamestream.isometric.nodes.nodeTypes[index])) {
        z--;
        continue;
      }
      // if (gamestream.isometricEngine.nodes.nodeVisible[index] == Visibility.Invisible) {
      //   z--;
      //   continue;
      // }
      callback(z, row, column);
      return;
    }
  }
}

class TouchController {
  var joystickCenterX = 0.0;
  var joystickCenterY = 0.0;
  var joystickX = 0.0;
  var joystickY = 0.0;
  var attack = false;

  static const maxDistance = 15.0;

  double get angle => angleBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);
  double get dis => distanceBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);

  void onClick() {
    joystickCenterX = engine.mousePositionX;
    joystickCenterY = engine.mousePositionY;
    joystickX = joystickCenterX;
    joystickY = joystickCenterY;
  }

  int getDirection(){
    if (engine.touches == 0) return Direction.None;
    return gamestream.io.convertRadianToDirection(angle);
  }

  void onMouseMoved(double x, double y){
    joystickX = engine.mousePositionX;
    joystickY = engine.mousePositionY;
  }

  void render(Canvas canvas){
    if (engine.touches == 0) return;

    if (engine.watchMouseLeftDown.value) {
      if (dis > maxDistance) {
        final radian = angleBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);
        joystickCenterX = joystickX - adj(radian, maxDistance);
        joystickCenterY = joystickY - opp(radian, maxDistance);
      }
    }
  }
}