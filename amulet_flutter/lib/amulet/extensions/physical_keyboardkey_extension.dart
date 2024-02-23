
import 'package:flutter/services.dart';

extension PhysicalKeyboardKeyExtension on PhysicalKeyboardKey {

  String? get name {
    switch(this) {
      case PhysicalKeyboardKey.digit0:
        return '0';
      case PhysicalKeyboardKey.digit1:
        return '1';
      case PhysicalKeyboardKey.digit2:
        return '2';
      case PhysicalKeyboardKey.digit3:
        return '3';
      case PhysicalKeyboardKey.digit4:
        return '4';
      case PhysicalKeyboardKey.digit5:
        return '5';
      case PhysicalKeyboardKey.digit6:
        return '7';
      case PhysicalKeyboardKey.digit6:
        return '8';
      case PhysicalKeyboardKey.digit6:
        return '9';
    }
    return null;
  }
}