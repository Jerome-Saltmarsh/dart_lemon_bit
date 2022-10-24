
import 'package:gamestream_flutter/game_editor.dart';
import 'package:lemon_engine/engine.dart';

void onMouseClickedEditMode(){
  if (Engine.keyPressedShiftLeft){
    GameEditor.selectMouseGameObject();
    return;
  }
  GameEditor.selectMouseBlock();
  GameEditor.actionRecenterCamera();
}









