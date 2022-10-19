
import 'package:flutter/services.dart';
import 'package:lemon_engine/engine.dart';

class GameIO {
  static bool get keyPressedSpace => Engine.keyPressed(LogicalKeyboardKey.space);
}