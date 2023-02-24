
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

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
      Engine.onPanStart = onPanStart;
      Engine.onPanUpdate = onPanUpdate;
      Engine.onPanEnd = onPanEnd;
      Engine.onTapDown = onTapDown;
      Engine.onTap = onTap;
      Engine.onLongPressDown = onLongPressDown;
      Engine.onSecondaryTapDown = onSecondaryTapDown;
      Engine.onKeyDown = onRawKeyDownEvent;
      Engine.onLeftClicked = onMouseClickedLeft;
      Engine.onRightClicked = onMouseClickedRight;
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
      ClientState.touchButtonSide.value = (details.globalPosition.dx < Engine.screenCenterX);
  }

  static void onPanUpdate(DragUpdateDetails details) {
    const sensitivity = 2.0;
    final velocityX = details.delta.dx * sensitivity;
    final velocityY = details.delta.dy * sensitivity;
    if (!_panning) {
      _panning = true;
      previousVelocityX2 = velocityX;
      previousVelocityY2 = velocityY;
      previousVelocityX = velocityX;
      previousVelocityY = velocityY;
    }
    final combinedVelocityX = (velocityX + previousVelocityX + previousVelocityX2) / 3;
    final combinedVelocityY = (velocityY + previousVelocityY + previousVelocityY2) / 3;

    touchCursorWorldX += combinedVelocityX;
    touchCursorWorldY += combinedVelocityY;
    const sensitivityLoss = 0.8;
    previousVelocityX2 = previousVelocityX * sensitivityLoss;
    previousVelocityY2 = previousVelocityY * sensitivityLoss;
    previousVelocityX = velocityX * sensitivityLoss;
    previousVelocityY = velocityY * sensitivityLoss;
  }

  static void onPanEnd(DragEndDetails details){
    touchscreenDirectionMove = Direction.None;
    touchPanning = false;
    if (inputModeTouch) {
      GameActions.setTarget();
    }

    _panning = false;
  }

  static void onKeyHeld(RawKeyDownEvent key, int duration) {
     // print('onKeyHeld(key: ${key.logicalKey.debugName}, duration: $duration)');
  }

  static void onKeyPressed(RawKeyDownEvent event) {
     ClientEvents.onKeyPressed(event.logicalKey);
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

  // static double get touchMouseWorldX  =>
  //   Engine.screenToWorldX(touchCursorScreenX);
  //
  // static double get touchMouseWorldY  =>
  //     Engine.screenToWorldY(touchCursorScreenY);

  static double get touchMouseWorldZ => GamePlayer.position.z;
  // static double get touchMouseRenderX => GameConvert.getRenderX(touchMouseWorldX, touchMouseWorldY, touchMouseWorldZ);
  // static double get touchMouseRenderY => GameConvert.getRenderY(touchMouseWorldX, touchMouseWorldY, touchMouseWorldZ);
  // static double get touchScreenX => Engine.worldToScreenX(touchMouseRenderX);
  // static double get touchScreenY => Engine.worldToScreenY(touchMouseRenderY);

  static double getCursorWorldX() {
    if (inputModeTouch){
      return touchCursorWorldX;
    } else {
      return Engine.mouseWorldX;
    }
  }
  static double getCursorWorldY() {
    if (inputModeTouch){
      return touchCursorWorldY;
    } else {
      return Engine.mouseWorldY;
    }
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


  static void setCursorAction(int cursorAction) {
    GameIO.touchscreenCursorAction = CursorAction.None;
  }

  static int getCursorAction() {
    if (GameState.editMode) return CursorAction.None;

    if (inputModeTouch){
       return GameIO.touchscreenCursorAction;
    }

    if (inputModeKeyboard) {

      if (Engine.watchMouseLeftDown.value)
        return CursorAction.Mouse_Left_Click;
      if (Engine.mouseRightDown.value)
        return CursorAction.Mouse_Right_Click;
      if (Engine.keyPressed(ClientConstants.Key_Throw_Grenade))
        return CursorAction.Key_Space;
      return CursorAction.None;
    }
    if (performActionPrimary) {
      performActionPrimary = false;
      return CursorAction.Set_Target;
    }
    return CursorAction.None;
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

    if (key == PhysicalKeyboardKey.keyZ) {
      // GameState.spawnParticleFirePurple(
      //     x: mouseGridX,
      //     y: mouseGridY,
      //     z: GamePlayer.position.z,
      // );

      GameState.spawnParticleShotSmoke(
          x: mouseGridX,
          y: mouseGridY,
          z: GamePlayer.position.z,
          angle: 0,
          speed: 0,
      );
      return;
    }

    if (GameState.playMode) {
      if (key == PhysicalKeyboardKey.keyG)
        return GameNetwork.sendClientRequestTeleport();
      return;
    }

    // EDIT MODE
    if (key == PhysicalKeyboardKey.keyF) return GameEditor.paint();
    if (key == PhysicalKeyboardKey.keyR) return GameEditor.selectPaintType();
    if (key == PhysicalKeyboardKey.keyE) return GameEditor.raise();
    if (key == PhysicalKeyboardKey.keyG) {
      if (GameEditor.gameObjectSelected.value) {
        GameNetwork.sendGameObjectRequestMoveToMouse();
      } else {
        GameCamera.cameraSetPositionGrid(GameEditor.row, GameEditor.column, GameEditor.z);
      }
    }

    if (key == PhysicalKeyboardKey.digit1)
      return GameEditor.delete();
    if (key == PhysicalKeyboardKey.digit2)
      return GameEditor.paintGrass();
    if (key == PhysicalKeyboardKey.digit3)
      return GameEditor.paintWater();
    // if (key == PhysicalKeyboardKey.digit4)
    //   return GameEditor.paintBricks();
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

    ClientState.showAllItems = Engine.keyPressed(LogicalKeyboardKey.keyQ);
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