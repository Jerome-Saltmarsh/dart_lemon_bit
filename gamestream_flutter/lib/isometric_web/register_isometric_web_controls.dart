import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric_web/on_mouse_clicked_left.dart';
import 'package:gamestream_flutter/isometric_web/on_mouse_clicked_right.dart';
import 'package:lemon_engine/engine.dart';

import 'on_keyboard_event.dart';

void isometricWebControlsRegister(){
  Engine.onLeftClicked = onMouseClickedLeft;
  Engine.onRightClicked = onMouseClickedRight;
  RawKeyboard.instance.addListener(onKeyboardEvent);
}

void isometricWebControlsDeregister(){
  RawKeyboard.instance.removeListener(onKeyboardEvent);
}

