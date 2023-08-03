
import 'package:gamestream_flutter/functions/get_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/mixins/isometric_component.dart';
import 'package:gamestream_flutter/lemon_ioc/updatable.dart';
import 'package:lemon_byte/byte_writer.dart';

import '../../../library.dart';
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
  Future initializeComponent(sharedPreferences) async {
    touchController = TouchController();
    engine.deviceType.onChanged(onDeviceTypeChanged);
    engine.onScreenSizeChanged = onScreenSizeChanged;
  }

  @override
  void onComponentUpdate() {

    if (!network.websocket.connected)
      return;

    if (!options.gameRunning.value) {
      writeByte(ClientRequest.Update);
      applyKeyboardInputToUpdateBuffer();
      sendUpdateBuffer();
      return;
    }

    readPlayerInputEdit();
    applyKeyboardInputToUpdateBuffer();
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
    var z = scene.totalZ - 1;
    final mouseWorldX = engine.mouseWorldX;
    final mouseWorldY = engine.mouseWorldY;
    while (z >= 0){
      final row = convertWorldToRow(mouseWorldX, mouseWorldY, z * Node_Height);
      final column = convertWorldToColumn(mouseWorldX, mouseWorldY, z * Node_Height);
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
  void applyKeyboardInputToUpdateBuffer() {

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

    writeByte(io.getInputAsByte());
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
  }

  void sendUpdateBuffer() {
    final bytes = compile();
    updateSize.value = bytes.length;
    network.websocket.send(bytes);
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


  void readPlayerInputEdit() {
    if (!options.edit.value)
      return;

    if (engine.keyPressedSpace) {
      engine.panCamera();
    }
    if (engine.keyPressed(KeyCode.Delete)) {
      editor.delete();
    }
    if (getInputDirectionKeyboard() != IsometricDirection.None) {
      // actionSetModePlay();
    }
    return;
  }

}

