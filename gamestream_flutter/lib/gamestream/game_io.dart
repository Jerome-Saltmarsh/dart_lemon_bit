
import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_actions.dart';
import 'package:lemon_byte/byte_writer.dart';

import '../library.dart';
import 'isometric/components/isometric_render.dart';
import 'isometric/isometric.dart';


class GameIO with ByteWriter {

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

  final panDistance = Watch(0.0);
  final panDirection = Watch(0.0);
  final touchController = TouchController();
  final Isometric isometric;
  late final inputMode = Watch(InputMode.Keyboard, onChanged: isometric.events.onChangedInputMode);

  GameIO(this.isometric);

  bool get inputModeTouch => inputMode.value == InputMode.Touch;

  bool get inputModeKeyboard => inputMode.value == InputMode.Keyboard;

  void recenterCursor(){
    touchCursorWorldX = isometric.player.renderX;
    touchCursorWorldY = isometric.player.renderY;
  }

  void detectInputMode() =>
    inputMode.value = engine.deviceIsComputer
        ? InputMode.Keyboard
        : InputMode.Touch;

  void actionToggleInputMode() =>
    inputMode.value = inputModeKeyboard ? InputMode.Touch : InputMode.Keyboard;

  double get touchMouseWorldZ => isometric.player.position.z;

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

  int getDirection() => inputModeKeyboard ? getInputDirectionKeyboard() : getDirectionTouchScreen();

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

  void mouseRaycast(Function(int z, int row, int column) callback){
    final nodes = isometric.scene;
    var z = nodes.totalZ - 1;
    final mouseWorldX = engine.mouseWorldX;
    final mouseWorldY = engine.mouseWorldY;
    while (z >= 0){
      final row = IsometricRender.convertWorldToRow(mouseWorldX, mouseWorldY, z * Node_Height);
      final column = IsometricRender.convertWorldToColumn(mouseWorldX, mouseWorldY, z * Node_Height);
      if (row < 0) break;
      if (column < 0) break;
      if (row >= nodes.totalRows) break;
      if (column >= nodes.totalColumns) break;
      if (z >= nodes.totalZ) break;
      final index = nodes.getIndexZRC(z, row, column);
      if (NodeType.isRainOrEmpty(nodes.nodeTypes[index])) {
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
  void applyKeyboardInputToUpdateBuffer() {
    clear();
    writeByte(ClientRequest.Update);
    writeByte(gamestream.io.getInputAsByte());
    writeInt16(engine.mouseWorldX.toInt());
    writeInt16(engine.mouseWorldY.toInt());
    writeInt16(engine.Screen_Left.toInt());
    writeInt16(engine.Screen_Top.toInt());
    writeInt16(engine.Screen_Right.toInt());
    writeInt16(engine.Screen_Bottom.toInt());
  }

  void sendUpdateBuffer() => gamestream.network.send(compile());
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

  int getDirection() =>
      engine.touches == 0 ? IsometricDirection.None : IsometricDirection.fromRadian(angle);

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