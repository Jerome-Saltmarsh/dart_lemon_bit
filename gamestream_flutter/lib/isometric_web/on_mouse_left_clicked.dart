
import 'package:gamestream_flutter/isometric/actions/action_editor_paint_mouse.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/enums/edit_tool.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/watches/edit_tool.dart';
import 'package:gamestream_flutter/isometric_web/on_keyboard_event.dart';

void onMouseLeftClicked(){
  if (playModeEdit) {
     onMouseClickedEditMode();
  }
}

void onMouseClickedEditMode(){
  switch(editTool.value){
    case EditTool.Select:
      if (shiftLeftDown){
       edit.selectMouseGameObject();
        return;
      }
      edit.selectMouseBlock();
      break;
    case EditTool.Paint:
      actionEditorPaintMouse();
      break;
  }
}









