
import 'package:gamestream_flutter/isometric/actions/action_editor_paint_mouse.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/enums/edit_tool.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/watches/edit_tool.dart';

void onMouseLeftClicked(){
  if (playModeEdit) {
     onMouseClickedEditMode();
  }
}

void onMouseClickedEditMode(){
  switch(editTool.value){
    case EditTool.Select:
      edit.selectMouse();
      break;
    case EditTool.Paint:
      actionEditorPaintMouse();
      break;
  }
}









