
import 'package:gamestream_flutter/isometric/actions/action_editor_paint_mouse.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/enums/edit_tool.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/utils/mouse_raycast.dart';
import 'package:gamestream_flutter/isometric/watches/edit_tool.dart';

void onMouseLeftClicked(){
  if (playModeEdit) {
     onMouseClickedEditMode();
  }
}

void onMouseClickedEditMode(){
  // for (var i = 0; i < totalNpcs; i++){
  //   final npc = npcs[i];
  //   final distance = getDistanceFromMouse(npc);
  //   if (distance < 100){
  //     editorSelectedObject.value = npc;
  //     return;
  //   }
  // }

  switch(editTool.value){
    case EditTool.Select:
      mouseRaycast(edit.selectBlock);
      break;
    case EditTool.Paint:
      actionEditorPaintMouse();
      break;
  }
}









