
import 'package:gamestream_flutter/game_editor.dart';
import 'package:gamestream_flutter/isometric/editor/actions/editor_action_recenter_camera.dart';
import 'package:lemon_engine/engine.dart';

void onMouseClickedEditMode(){
  if (Engine.keyPressedShiftLeft){
    GameEditor.selectMouseGameObject();
    return;
  }
  GameEditor.selectMouseBlock();
  editorActionRecenterCamera();
}









