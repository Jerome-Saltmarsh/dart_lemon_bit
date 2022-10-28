
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'library.dart';


class GameIO {
  static var touchPanning = false;
  static var touchscreenDirectionMove = Direction.None;
  static var touchscreenRadianInput = 0.0;
  static var touchscreenRadianMove = 0.0;
  static var touchscreenRadianPerform = 0.0;
  static var touchscreenMouseX = 0.0;
  static var touchscreenMouseY = 0.0;
  static var touchPerformPrimary = false;

  // GETTERS
  static final inputMode = Watch(InputMode.Keyboard);
  static bool get inputModeTouch => inputMode.value == InputMode.Touch;
  static bool get inputModeKeyboard => inputMode.value == InputMode.Keyboard;
  static bool get keyPressedSpace => Engine.keyPressed(LogicalKeyboardKey.space);

  static var joystickLeftX = 0.0;
  static var joystickLeftY = 0.0;
  static var joystickLeftDown = false;
  var touchscreenAimX = 0.0;
  var touchscreenAimY = 0.0;
  static var panDistance = Watch(0.0);
  static var panDirection = Watch(0.0);

  static double get mouseGridX => GameConvert.convertWorldToGridX(Engine.mouseWorldX, Engine.mouseWorldY) + GamePlayer.position.z;
  static double get mouseGridY => GameConvert.convertWorldToGridY(Engine.mouseWorldX, Engine.mouseWorldY) + GamePlayer.position.z;

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
    GameState.joystickEngaged = true;
    GameState.joystickBaseX = details.globalPosition.dx;
    GameState.joystickBaseY = details.globalPosition.dy;
    GameState.joystickEndX = GameState.joystickBaseX;
    GameState.joystickEndY = GameState.joystickBaseY;
  }

  static var touchX1 = 0.0;
  static var touchX2 = 0.0;
  static var touchX3 = 0.0;
  static var touchX4 = 0.0;
  static var touchX5 = 0.0;
  static var touchY1 = 0.0;
  static var touchY2 = 0.0;
  static var touchY3 = 0.0;
  static var touchY4 = 0.0;
  static var touchY5 = 0.0;

  static void onPanUpdate(DragUpdateDetails details) {
    // print("onPanUpdate()");
    GameState.joystickEndX = details.globalPosition.dx;
    GameState.joystickEndY = details.globalPosition.dy;
    const maxDistance = 100.0;
    if (GameState.joystickDistance > maxDistance){
       final angle = GameState.joystickAngle;
       GameState.joystickBaseX = GameState.joystickEndX + Engine.calculateAdjacent(angle, maxDistance);
       GameState.joystickBaseY = GameState.joystickEndY + Engine.calculateOpposite(angle, maxDistance);
    }

    // final deltaDirection = details.delta.direction;
    // final deltaDistance = details.delta.distance;
    // panDistance.value = deltaDistance;
    // panDirection.value = deltaDirection;
    // if (deltaDistance < 1) return;
    // touchX5 = touchX4;
    // touchY5 = touchY4;
    // touchX4 = touchX3;
    // touchY4 = touchY3;
    // touchX3 = touchX2;
    // touchY3 = touchY2;
    // touchX2 = touchX1;
    // touchY2 = touchY1;
    // touchX1 = Engine.calculateAdjacent(deltaDirection, deltaDistance);
    // touchY1 = Engine.calculateOpposite(deltaDirection, deltaDistance);

    // if (!touchPanning) {
    //   touchPanning = true;
    //   touchX4 = touchX1;
    //   touchY4 = touchY1;
    //   touchX3 = touchX1;
    //   touchY3 = touchY1;
    //   touchX2 = touchX1;
    //   touchY2 = touchY1;
    // }
    // final totalX = touchX1 + (touchX2 * 0.8) + (touchX3 * 0.6) + (touchX4 * 0.4) + (touchX5 * 0.2);
    // final totalY = touchY1 + (touchY2 * 0.8) + (touchY3 * 0.6) + (touchY4 * 0.4) + (touchY5 * 0.2);
    // final angle = Engine.calculateAngle(totalX, totalY);
    // final distance = Engine.calculateHypotenuse(totalX, totalY);
    touchscreenDirectionMove = convertRadianToDirection(GameState.joystickAngle + Engine.PI);
  }

  static void onPanEnd(DragEndDetails details){
    // print('onPanEnd()');
    touchscreenDirectionMove = Direction.None;
    touchPanning = false;
    GameState.joystickEngaged = false;
  }

  static void onKeyHeld(RawKeyDownEvent key, int duration) {
     // print('onKeyHeld(key: ${key.logicalKey.debugName}, duration: $duration)');
  }

  static void onKeyPressed(RawKeyDownEvent event) {
     if (event.logicalKey == LogicalKeyboardKey.keyX) {
       actionToggleInputMode();
     }
     if (event.logicalKey == LogicalKeyboardKey.keyP){
       GameActions.toggleDebugMode();
     }
     if (event.logicalKey == LogicalKeyboardKey.enter){
       GameActions.messageBoxShow();
     }
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

  static void onTapDown(TapDownDetails details) {
    // print("onTapDown()");
    if (inputModeTouch) {
       touchscreenMouseX = Engine.screenToWorldX(details.globalPosition.dx);
       touchscreenMouseY = Engine.screenToWorldY(details.globalPosition.dy);
       touchPerformPrimary = true;
    }
  }

  static double getMouseX() {
     if (inputModeTouch){
       return Engine.screenCenterWorldX + Engine.calculateAdjacent(Engine.PI_2 - touchscreenRadianPerform + Engine.PI_Half, 100);
       // return touchscreenMouseX;
     }
     return Engine.mouseWorldX;
  }

  static double getMouseY() {
    if (inputModeTouch){
      return Engine.screenCenterWorldY + Engine.calculateOpposite(Engine.PI_2 - touchscreenRadianPerform + Engine.PI_Half, 100);
      // return touchscreenMouseY;
    }
    return Engine.mouseWorldY;
  }

  static int getDirection() {
    final keyboardDirection = getDirectionKeyboard();
    if (keyboardDirection != Direction.None) return keyboardDirection;
    return inputModeKeyboard ? keyboardDirection : touchscreenDirectionMove;
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
    if (touchPerformPrimary) {
      touchPerformPrimary = false;
      return true;
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
    if (key == PhysicalKeyboardKey.keyZ) {
      GameState.spawnParticleFirePurple(
          x: mouseGridX,
          y: mouseGridY,
          z: GamePlayer.position.z,
      );
      return;
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
        GameActions.cameraSetPositionGrid(GameEditor.row, GameEditor.column, GameEditor.z);
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

  static void onMouseClickedEditMode(){
    if (Engine.keyPressedShiftLeft){
      GameEditor.selectMouseGameObject();
      return;
    }
    GameEditor.selectMouseBlock();
    GameEditor.actionRecenterCamera();
  }

  static void readPlayerInput() {

    if (GameState.edit.value) {
      return readPlayerInputEdit();
    }
  }

  static void readPlayerInputEdit() {
    if (Engine.keyPressed(LogicalKeyboardKey.space)) {
      Engine.panCamera();
    }
    if (Engine.keyPressed(LogicalKeyboardKey.delete)) {
      GameEditor.delete();
    }
    if (GameIO.getDirectionKeyboard() != Direction.None) {
      GameActions.actionSetModePlay();
    }
    return;
  }

  static void mouseRaycast(Function(int z, int row, int column) callback){
    var z = GameState.nodesTotalZ - 1;
    while (z >= 0){
      final row = GameConvert.convertWorldToRow(Engine.mouseWorldX, Engine.mouseWorldY, z * tileHeight);
      final column = GameConvert.convertWorldToColumn(Engine.mouseWorldX, Engine.mouseWorldY, z * tileHeight);
      if (row < 0) break;
      if (column < 0) break;
      if (row >= GameState.nodesTotalRows) break;
      if (column >= GameState.nodesTotalColumns) break;
      if (z >= GameState.nodesTotalZ) break;
      final index = GameState.getNodeIndexZRC(z, row, column);
      if (GameState.nodesType[index] == NodeType.Empty
          ||
          NodeType.isRain(GameState.nodesType[index])
      ) {
        z--;
        continue;
      }
      if (!GameState.nodesVisible[index]) {
        z--;
        continue;
      }
      callback(z, row, column);
      return;
    }
  }

}