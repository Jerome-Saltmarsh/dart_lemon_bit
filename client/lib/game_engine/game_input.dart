
import 'package:flutter/services.dart';

const LogicalKeyboardKey w = LogicalKeyboardKey.keyW;

bool get keyPressedUpArrow => keyPressed(LogicalKeyboardKey.arrowUp);
bool get keyPressedRightArrow => keyPressed(LogicalKeyboardKey.arrowRight);
bool get keyPressedDownArrow => keyPressed(LogicalKeyboardKey.arrowDown);
bool get keyPressedLeftArrow => keyPressed(LogicalKeyboardKey.arrowLeft);

bool get keyPressedW => keyPressed(w);
bool get keyPressedA => keyPressed(LogicalKeyboardKey.keyA);
bool get keyPressedS => keyPressed(LogicalKeyboardKey.keyS);
bool get keyPressedD => keyPressed(LogicalKeyboardKey.keyD);
bool get keyPressedF => keyPressed(LogicalKeyboardKey.keyF);

// methods
bool keyPressed(LogicalKeyboardKey key) {
  return RawKeyboard.instance.keysPressed.contains(key);
}