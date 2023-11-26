
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric_web/on_keyboard_event.dart';

void onMouseLeftClicked(){
  if (playModeEdit) {
     onMouseClickedEditMode();
  }
}

void onMouseClickedEditMode(){
  if (shiftLeftDown){
    edit.selectMouseGameObject();
    return;
  }
  edit.selectMouseBlock();
}









