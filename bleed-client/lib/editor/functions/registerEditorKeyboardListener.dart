
import 'package:bleed_client/editor/events/onEditorKeyEvent.dart';
import 'package:flutter/services.dart';

void registerEditorKeyboardListener(){
  print("registerEditorKeyboardListener()");
  RawKeyboard.instance.addListener(onEditorKeyEvent);
}