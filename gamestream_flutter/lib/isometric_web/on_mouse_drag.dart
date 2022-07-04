
import 'package:gamestream_flutter/isometric/actions/action_editor_paint_mouse.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/enums/edit_tool.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:gamestream_flutter/isometric/watches/edit_tool.dart';

import '../isometric/play_mode.dart';

void onMouseDrag(){
  if (playModeEdit) {
    switch(editTool.value){
      case EditTool.Paint:
        actionEditorPaintMouse();
        break;
    }
  }
}