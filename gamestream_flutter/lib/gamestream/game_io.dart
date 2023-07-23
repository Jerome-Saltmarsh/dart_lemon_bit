
import 'dart:ui';

import 'package:lemon_byte/byte_writer.dart';

import '../library.dart';
import 'isometric/components/isometric_render.dart';
import 'isometric/isometric.dart';


class GameIO with ByteWriter {

  var previousMouseX = 0;
  var previousMouseY = 0;
  var previousScreenLeft = 0;
  var previousScreenRight = 0;
  var previousScreenTop = 0;
  var previousScreenBottom = 0;

  var joystickLeftX = 0.0;
  var joystickLeftY = 0.0;
  var joystickLeftDown = false;
  var touchscreenAimX = 0.0;
  var touchscreenAimY = 0.0;
  var touchCursorWorldX = 100.0;
  var touchCursorWorldY = 100.0;

  var previousVelocityX = 0.0;
  var previousVelocityY = 0.0;
  var previousVelocityX2 = 0.0;
  var previousVelocityY2 = 0.0;

  var touchPanning = false;
  var touchscreenDirectionMove = IsometricDirection.None;
  var touchscreenRadianInput = 0.0;
  var touchscreenRadianMove = 0.0;
  var touchscreenRadianPerform = 0.0;
  var performActionPrimary = false;

  final Isometric isometric;
  final updateSize = Watch(0);
  final panDistance = Watch(0.0);
  final panDirection = Watch(0.0);
  late final TouchController touchController;
  final inputMode = Watch(InputMode.Keyboard);

  GameIO(this.isometric) {
    touchController = TouchController(isometric);
  }

  bool get inputModeTouch => inputMode.value == InputMode.Touch;

  bool get inputModeKeyboard => inputMode.value == InputMode.Keyboard;

  void recenterCursor(){
    touchCursorWorldX = isometric.player.renderX;
    touchCursorWorldY = isometric.player.renderY;
  }

  void actionToggleInputMode() =>
    inputMode.value = inputModeKeyboard ? InputMode.Touch : InputMode.Keyboard;

  double get touchMouseWorldZ => isometric.player.position.z;

  /// compresses keyboard and mouse inputs into a single byte to send to the server
  int getInputAsByte(){

    var hex = getDirection();

    if (isometric.engine.watchMouseLeftDown.value) {
      hex = hex | ByteHex.Hex_16;
    }

    if (touchController.attack) {
      touchController.attack = false;
      hex = hex | ByteHex.Hex_16;
    }

    if (inputModeKeyboard) {

      if (isometric.engine.mouseRightDown.value) {
        hex = hex | ByteHex.Hex_32;
      }

      if (isometric.engine.keyPressedShiftLeft){
        hex = hex | ByteHex.Hex_64;
      }

      if (isometric.engine.keyPressedSpace){
        hex = hex | ByteHex.Hex_128;
      }
    }

    return hex;
  }

  double getCursorScreenX() {
     if (inputModeTouch){
       return isometric.engine.worldToScreenX(touchCursorWorldX);
     } else {
       return isometric.engine.mousePositionX;
     }
  }

  double getCursorScreenY() {
    if (inputModeTouch) {
      return isometric.engine.worldToScreenY(touchCursorWorldY);
    } else {
      return isometric.engine.mousePositionY;
    }
  }

  int getDirection() => inputModeKeyboard ? getInputDirectionKeyboard() : getDirectionTouchScreen();

  int getDirectionTouchScreen() {
    return touchController.getDirection();
  }

  int getInputDirectionKeyboard() {

    if (isometric.engine.keyPressed(KeyCode.W)) {
      if (isometric.engine.keyPressed(KeyCode.D)) {
        return InputDirection.Up_Right;
      }
      if (isometric.engine.keyPressed(KeyCode.A)) {
        return InputDirection.Up_Left;
      }
      return InputDirection.Up;
    }

    if (isometric.engine.keyPressed(KeyCode.S)) {
      if (isometric.engine.keyPressed(KeyCode.D)) {
        return InputDirection.Down_Right;
      }
      if (isometric.engine.keyPressed(KeyCode.A)) {
        return InputDirection.Down_Left;
      }
      return InputDirection.Down;
    }
    if (isometric.engine.keyPressed(KeyCode.A)) {
      return InputDirection.Left;
    }
    if (isometric.engine.keyPressed(KeyCode.D)) {
      return InputDirection.Right;
    }
    return InputDirection.None;
  }

  void mouseRaycast(Function(int z, int row, int column) callback){
    var z = isometric.totalZ - 1;
    final mouseWorldX = isometric.engine.mouseWorldX;
    final mouseWorldY = isometric.engine.mouseWorldY;
    while (z >= 0){
      final row = IsometricRender.convertWorldToRow(mouseWorldX, mouseWorldY, z * Node_Height);
      final column = IsometricRender.convertWorldToColumn(mouseWorldX, mouseWorldY, z * Node_Height);
      if (row < 0) break;
      if (column < 0) break;
      if (row >= isometric.totalRows) break;
      if (column >= isometric.totalColumns) break;
      if (z >= isometric.totalZ) break;
      final index = isometric.getIndexZRC(z, row, column);
      if (NodeType.isRainOrEmpty(isometric.nodeTypes[index])) {
        z--;
        continue;
      }
      callback(z, row, column);
      return;
    }
  }

  /// [0] Direction
  /// [1] Direction
  /// [2] Direction
  /// [3] Direction
  /// [4] Mouse_Left
  /// [5] Mouse_Right
  /// [6] Shift
  /// [7] Space
  void applyKeyboardInputToUpdateBuffer(Isometric isometric) {

    final mouseX = isometric.engine.mouseWorldX.toInt();
    final mouseY = isometric.engine.mouseWorldY.toInt();
    final screenLeft = isometric.engine.Screen_Left.toInt();
    final screenTop = isometric.engine.Screen_Top.toInt();
    final screenRight = isometric.engine.Screen_Right.toInt();
    final screenBottom = isometric.engine.Screen_Bottom.toInt();

    final diffMouseWorldX = mouseX - previousMouseX;
    final diffMouseWorldY = mouseY - previousMouseY;
    final diffScreenLeft = screenLeft - previousScreenLeft;
    final diffScreenTop = screenTop - previousScreenTop;
    final diffScreenRight = screenRight - previousScreenRight;
    final diffScreenBottom = screenBottom - previousScreenBottom;


    previousMouseX = mouseX;
    previousMouseY = mouseY;
    previousScreenLeft = screenLeft;
    previousScreenTop = screenTop;
    previousScreenRight = screenRight;
    previousScreenBottom = screenBottom;


    final changeMouseWorldX = ChangeType.fromDiff(diffMouseWorldX);
    final changeMouseWorldY = ChangeType.fromDiff(diffMouseWorldY);
    final changeScreenLeft = ChangeType.fromDiff(diffScreenLeft);
    final changeScreenTop = ChangeType.fromDiff(diffScreenTop);
    final changeScreenRight = ChangeType.fromDiff(diffScreenRight);
    final changeScreenBottom = ChangeType.fromDiff(diffScreenBottom);

    final compress1 = changeMouseWorldX
      | changeMouseWorldY << 2;

    final compress2 = changeScreenLeft
      | changeScreenTop << 2
      | changeScreenRight << 4
      | changeScreenBottom << 6;

    writeByte(isometric.io.getInputAsByte());
    writeByte(compress1);
    writeByte(compress2);

    if (changeMouseWorldX == ChangeType.Small){
      writeInt8(diffMouseWorldX);
    } else if (changeMouseWorldX == ChangeType.Big){
      writeInt16(mouseX);
    }

    if (changeMouseWorldY == ChangeType.Small){
      writeInt8(diffMouseWorldY);
    } else if (changeMouseWorldY == ChangeType.Big){
      writeInt16(mouseY);
    }

    if (changeScreenLeft == ChangeType.Small){
      writeInt8(diffScreenLeft);
    } else if (changeScreenLeft == ChangeType.Big){
      writeInt16(screenLeft);
    }

    if (changeScreenTop == ChangeType.Small){
      writeInt8(diffScreenTop);
    } else if (changeScreenTop == ChangeType.Big){
      writeInt16(screenTop);
    }

    if (changeScreenRight == ChangeType.Small){
      writeInt8(diffScreenRight);
    } else if (changeScreenRight == ChangeType.Big){
      writeInt16(screenRight);
    }

    if (changeScreenBottom == ChangeType.Small){
      writeInt8(diffScreenBottom);
    } else if (changeScreenBottom == ChangeType.Big){
      writeInt16(screenBottom);
    }

    // writeInt16(engine.mouseWorldX.toInt());
    // writeInt16(engine.mouseWorldY.toInt());
    // writeInt16(engine.Screen_Left.toInt());
    // writeInt16(engine.Screen_Top.toInt());
    // writeInt16(engine.Screen_Right.toInt());
    // writeInt16(engine.Screen_Bottom.toInt());
  }

  void sendUpdateBuffer() {
    final bytes = compile();
    updateSize.value = bytes.length;
    isometric.send(bytes);
  }

  void reset() {
    previousMouseX = 0;
    previousMouseY = 0;
    previousScreenLeft = 0;
    previousScreenTop = 0;
    previousScreenRight = 0;
    previousScreenBottom = 0;
  }
}

class TouchController {

  final Isometric isometric;

  var joystickCenterX = 0.0;
  var joystickCenterY = 0.0;
  var joystickX = 0.0;
  var joystickY = 0.0;
  var attack = false;

  static const maxDistance = 15.0;

  TouchController(this.isometric);

  double get angle => angleBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);
  double get dis => distanceBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);

  void onClick() {
    joystickCenterX = isometric.engine.mousePositionX;
    joystickCenterY = isometric.engine.mousePositionY;
    joystickX = joystickCenterX;
    joystickY = joystickCenterY;
  }

  int getDirection() =>
      isometric.engine.touches == 0 ? IsometricDirection.None : IsometricDirection.fromRadian(angle);

  void onMouseMoved(double x, double y){
    joystickX = isometric.engine.mousePositionX;
    joystickY = isometric.engine.mousePositionY;
  }

  void render(Canvas canvas){
    if (isometric.engine.touches == 0) return;

    if (isometric.engine.watchMouseLeftDown.value) {
      if (dis > maxDistance) {
        final radian = angleBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);
        joystickCenterX = joystickX - adj(radian, maxDistance);
        joystickCenterY = joystickY - opp(radian, maxDistance);
      }
    }
  }
}