
import 'package:amulet_common/src.dart';
import 'package:amulet_flutter/isometric/components/isometric_component.dart';
import 'package:amulet_flutter/packages/lemon_components/src.dart';
import 'package:flutter/services.dart';
import 'package:lemon_bit/src.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:lemon_watch/src.dart';
import 'classes/touch_controller.dart';

class IsometricIO with ByteWriter, IsometricComponent implements Updatable {

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

  final updateSize = Watch(0);
  final panDistance = Watch(0.0);
  final panDirection = Watch(0.0);
  final inputMode = Watch(InputMode.Keyboard);
  late final TouchController touchController;

  @override
  Future onComponentInit(sharedPreferences) async {
    touchController = TouchController();
    engine.deviceType.onChanged(onDeviceTypeChanged);
    // engine.onScreenSizeChanged = onScreenSizeChanged;
  }

  @override
  void onComponentUpdate() {

    if (!server.connected){
      return;
    }


    if (!options.gameRunning.value) {
      writeByte(NetworkRequest.Update);
      applyComputerInputToUpdateBuffer();
      sendUpdateBuffer();
      return;
    }

    applyComputerInputToUpdateBuffer();
    sendUpdateBuffer();
  }

  bool get inputModeTouch => inputMode.value == InputMode.Touch;

  bool get inputModeKeyboard => inputMode.value == InputMode.Keyboard;

  double get touchMouseWorldZ => player.position.z;

  void recenterCursor(){
    touchCursorWorldX = player.renderX;
    touchCursorWorldY = player.renderY;
  }

  void actionToggleInputMode() =>
    inputMode.value = inputModeKeyboard ? InputMode.Touch : InputMode.Keyboard;

  /// compresses keyboard and mouse inputs into a single byte to send to the server
  int getComputerInputAsByte(){

    var hex = getDirection();

    if (engine.watchMouseLeftDown.value) {
      hex = hex | ByteHex.Hex_16;
    }

    if (touchController.attack) {
      touchController.attack = false;
      hex = hex | ByteHex.Hex_16;
    }

    if (inputModeKeyboard) {

      if (engine.mouseRightDown.value) {
        hex = hex | ByteHex.Hex_32;
      }

      if (engine.keyPressedShiftLeft){
        hex = hex | ByteHex.Hex_64;
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

  void onScreenSizeChanged(
      double previousWidth,
      double previousHeight,
      double newWidth,
      double newHeight,
      ) => detectInputMode();


  double getCursorScreenY() {
    if (inputModeTouch) {
      return engine.worldToScreenY(touchCursorWorldY);
    } else {
      return engine.mousePositionY;
    }
  }

  int getDirection() => inputModeKeyboard ? getInputDirectionKeyboard() : getDirectionTouchScreen();

  int getDirectionTouchScreen() {
    // return touchController.getDirection();
    return 0;
  }

  int getInputDirectionKeyboard() {

    const up = PhysicalKeyboardKey.keyW;
    const right = PhysicalKeyboardKey.keyD;
    const down = PhysicalKeyboardKey.keyS;
    const left = PhysicalKeyboardKey.keyA;

    final engine = this.engine;

    if (engine.keyPressed(up)) {
      if (engine.keyPressed(right)) {
        return InputDirection.Up_Right;
      }
      if (engine.keyPressed(left)) {
        return InputDirection.Up_Left;
      }
      return InputDirection.Up;
    }

    if (engine.keyPressed(down)) {
      if (engine.keyPressed(right)) {
        return InputDirection.Down_Right;
      }
      if (engine.keyPressed(left)) {
        return InputDirection.Down_Left;
      }
      return InputDirection.Down;
    }
    if (engine.keyPressed(left)) {
      return InputDirection.Left;
    }
    if (engine.keyPressed(right)) {
      return InputDirection.Right;
    }
    return InputDirection.None;
  }

  void mouseRaycast(Function(int z, int row, int column) callback){
    var z = scene.totalZ - 1;
    final mouseWorldX = engine.mouseWorldX;
    final mouseWorldY = engine.mouseWorldY;
    while (z >= 0){
      final row = convertRenderToRow(mouseWorldX, mouseWorldY, z * Node_Height);
      final column = convertRenderToColumn(mouseWorldX, mouseWorldY, z * Node_Height);
      if (row < 0) break;
      if (column < 0) break;
      if (row >= scene.totalRows) break;
      if (column >= scene.totalColumns) break;
      if (z >= scene.totalZ) break;
      final index = scene.getIndexZRC(z, row, column);
      if (NodeType.isRainOrEmpty(scene.nodeTypes[index])) {
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
  void applyComputerInputToUpdateBuffer() {

    final engine = this.engine;
    final mouseX = engine.mouseWorldX.toInt();
    final mouseY = engine.mouseWorldY.toInt();
    final screenLeft = engine.Screen_Left.toInt();
    final screenTop = engine.Screen_Top.toInt();
    final screenRight = engine.Screen_Right.toInt();
    final screenBottom = engine.Screen_Bottom.toInt();

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

    if (options.editing){
      writeByte(0);
    } else {
      writeByte(getComputerInputAsByte());
    }

    writeByte(compress1);
    writeByte(compress2);

    if (changeMouseWorldX == ChangeType.Delta){
      writeInt8(diffMouseWorldX);
    } else if (changeMouseWorldX == ChangeType.Absolute){
      writeInt16(mouseX);
    }

    if (changeMouseWorldY == ChangeType.Delta){
      writeInt8(diffMouseWorldY);
    } else if (changeMouseWorldY == ChangeType.Absolute){
      writeInt16(mouseY);
    }

    if (changeScreenLeft == ChangeType.Delta){
      writeInt8(diffScreenLeft);
    } else if (changeScreenLeft == ChangeType.Absolute){
      writeInt16(screenLeft);
    }

    if (changeScreenTop == ChangeType.Delta){
      writeInt8(diffScreenTop);
    } else if (changeScreenTop == ChangeType.Absolute){
      writeInt16(screenTop);
    }

    if (changeScreenRight == ChangeType.Delta){
      writeInt8(diffScreenRight);
    } else if (changeScreenRight == ChangeType.Absolute){
      writeInt16(screenRight);
    }

    if (changeScreenBottom == ChangeType.Delta){
      writeInt8(diffScreenBottom);
    } else if (changeScreenBottom == ChangeType.Absolute){
      writeInt16(screenBottom);
    }
  }

  void sendUpdateBuffer() {
    final bytes = compile();
    updateSize.value = bytes.length;
    server.send(bytes);
  }

  void reset() {
    previousMouseX = 0;
    previousMouseY = 0;
    previousScreenLeft = 0;
    previousScreenTop = 0;
    previousScreenRight = 0;
    previousScreenBottom = 0;
  }  
  
  void onDeviceTypeChanged(int deviceType){
    detectInputMode();
  }
  
  void detectInputMode() =>
      inputMode.value = engine.deviceIsComputer
          ? InputMode.Keyboard
          : InputMode.Touch;

}

