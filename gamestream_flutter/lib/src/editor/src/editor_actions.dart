
import 'package:gamestream_flutter/library.dart';

class EditorActions {

  static void toggleWindowEnabledScene(){
    EditorState.windowEnabledScene.value = !EditorState.windowEnabledScene.value;
  }
}