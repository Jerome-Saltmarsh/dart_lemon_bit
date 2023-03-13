
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/library.dart';

class ClientConstants {
  static const Area_Type_Duration = 150;
  static final Key_Inventory = LogicalKeyboardKey.keyI;
  static final Key_Zoom = LogicalKeyboardKey.keyF;
  static final Key_Settings = LogicalKeyboardKey.digit0;
  static final Key_Duplicate = LogicalKeyboardKey.keyV;
  static final Key_Auto_Attack = LogicalKeyboardKey.space;
  static final Key_Message = LogicalKeyboardKey.enter;
  static final Key_Toggle_Debug_Mode = KeyCode.P;
  static final Key_Toggle_Map = KeyCode.M;

  static const Mouse_Translation_Sensitivity = 0.1;

  static const Hot_Keys = [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.keyQ,
    LogicalKeyboardKey.keyE,
  ];
}