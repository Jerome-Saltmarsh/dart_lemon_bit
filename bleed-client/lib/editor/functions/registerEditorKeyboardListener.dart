
import 'package:bleed_client/editor/events/onEditorKeyEvent.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/game.dart';

import '../editor.dart';

void registerEditorKeyboardListener(){
  print("registerEditorKeyboardListener()");
  keyboardEvents.listen(editor.onKeyboardEvent);
}
