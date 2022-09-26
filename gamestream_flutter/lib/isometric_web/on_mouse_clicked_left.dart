
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/editor/actions/editor_action_recenter_camera.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric_web/on_keyboard_event.dart';

void onMouseClickedLeft(){
  if (game.edit.value) {
     onMouseClickedEditMode();
  }
}

void onMouseClickedEditMode(){
  if (shiftLeftDown){
    edit.selectMouseGameObject();
    return;
  }
  edit.selectMouseBlock();
  editorActionRecenterCamera();
}









