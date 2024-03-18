import 'package:flutter/services.dart';

extension PhysicalKeyboardKeyExtension on PhysicalKeyboardKey {

  String get name {
    switch (this) {
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
        return '6';
      case PhysicalKeyboardKey.digit7:
        return '7';
      case PhysicalKeyboardKey.digit8:
        return '8';
      case PhysicalKeyboardKey.digit9:
        return '9';
      case PhysicalKeyboardKey.keyA:
        return 'a';
      case PhysicalKeyboardKey.keyB:
        return 'b';
      case PhysicalKeyboardKey.keyC:
        return 'c';
      case PhysicalKeyboardKey.keyD:
        return 'd';
      case PhysicalKeyboardKey.keyE:
        return 'e';
      case PhysicalKeyboardKey.keyF:
        return 'f';
      case PhysicalKeyboardKey.keyG:
        return 'g';
      case PhysicalKeyboardKey.keyH:
        return 'h';
      case PhysicalKeyboardKey.keyI:
        return 'i';
      case PhysicalKeyboardKey.keyJ:
        return 'j';
      case PhysicalKeyboardKey.keyK:
        return 'k';
      case PhysicalKeyboardKey.keyL:
        return 'l';
      case PhysicalKeyboardKey.keyM:
        return 'm';
      case PhysicalKeyboardKey.keyN:
        return 'n';
      case PhysicalKeyboardKey.keyO:
        return 'o';
      case PhysicalKeyboardKey.keyP:
        return 'p';
      case PhysicalKeyboardKey.keyQ:
        return 'q';
      case PhysicalKeyboardKey.keyR:
        return 'r';
      case PhysicalKeyboardKey.keyS:
        return 's';
      case PhysicalKeyboardKey.keyT:
        return 't';
      case PhysicalKeyboardKey.keyU:
        return 'u';
      case PhysicalKeyboardKey.keyV:
        return 'v';
      case PhysicalKeyboardKey.keyW:
        return 'w';
      case PhysicalKeyboardKey.keyX:
        return 'x';
      case PhysicalKeyboardKey.keyY:
        return 'y';
      case PhysicalKeyboardKey.keyZ:
        return 'z';
      case PhysicalKeyboardKey.enter:
        return 'enter';
      case PhysicalKeyboardKey.tab:
        return 'tab';
      case PhysicalKeyboardKey.space:
        return 'space';
      case PhysicalKeyboardKey.arrowUp:
        return 'arrowUp';
      case PhysicalKeyboardKey.arrowDown:
        return 'arrowDown';
      case PhysicalKeyboardKey.arrowLeft:
        return 'arrowLeft';
      case PhysicalKeyboardKey.arrowRight:
        return 'arrowRight';
      default:
        throw Exception('PhysicalKeyboardKeyExtension.name(${this})');
    }
  }
}
