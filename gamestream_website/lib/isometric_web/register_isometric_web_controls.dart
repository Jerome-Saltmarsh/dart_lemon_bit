import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric_web/on_mouse_left_clicked.dart';
import 'package:gamestream_flutter/isometric_web/on_mouse_right_clicked.dart';
import 'package:lemon_engine/callbacks.dart';
import 'package:lemon_engine/engine.dart';

import 'on_keyboard_event.dart';

final keys = KeyMap();

void isometricWebControlsRegister(){
  print("isometricWebControlsRegister()");
  onLeftClicked = onMouseLeftClicked;
  engine.callbacks.onRightClicked = onMouseRightClicked;
  RawKeyboard.instance.addListener(onKeyboardEvent);
}

void isometricWebControlsDeregister(){
  print("isometricWebControlsDeregister()");
  RawKeyboard.instance.removeListener(onKeyboardEvent);
}

class KeyMap {
  final interact = LogicalKeyboardKey.keyA;
  final runUp = LogicalKeyboardKey.keyW;
  final runRight = LogicalKeyboardKey.keyD;
  final runDown = LogicalKeyboardKey.keyS;
  final runLeft = LogicalKeyboardKey.keyA;
  final throwGrenade = LogicalKeyboardKey.keyG;
  final equip1 = LogicalKeyboardKey.digit1;
  final equip2 = LogicalKeyboardKey.digit2;
  final equip3 = LogicalKeyboardKey.digit3;
  final equip4 = LogicalKeyboardKey.digit4;
  final equip5 = LogicalKeyboardKey.digit5;
  final equip6 = LogicalKeyboardKey.digit6;
  final debug = LogicalKeyboardKey.keyZ;
  final equip1B = LogicalKeyboardKey.keyQ;
  final equip2B = LogicalKeyboardKey.keyE;
  final equip3B = LogicalKeyboardKey.keyF;
  final equip4B = LogicalKeyboardKey.keyC;
  final speakLetsGo = LogicalKeyboardKey.digit9;
  final speakLetsGreeting = LogicalKeyboardKey.digit8;
  final waitASecond = LogicalKeyboardKey.digit0;
  final speak = LogicalKeyboardKey.enter;
  final toggleLantern = LogicalKeyboardKey.keyL;
  final toggleAudio = LogicalKeyboardKey.keyM;
  final hourForwards = LogicalKeyboardKey.arrowRight;
  final hourBackwards = LogicalKeyboardKey.arrowLeft;
  final toggleObjectsDestroyable = LogicalKeyboardKey.keyP;
  final teleport = LogicalKeyboardKey.keyG;
  final spawnZombie = LogicalKeyboardKey.keyZ;
  final respawn = LogicalKeyboardKey.keyN;
  final cubeFace0 = LogicalKeyboardKey.keyO;
  final cubeFaceI = LogicalKeyboardKey.keyI;
}
