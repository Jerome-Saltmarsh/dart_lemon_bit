
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/npcs.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/utils/get_distance_from_mouse.dart';
import 'package:gamestream_flutter/isometric/utils/mouse_raycast.dart';
import 'package:gamestream_flutter/isometric/watches/editor_selected_object.dart';

void onMouseLeftClicked(){
  if (playModeEdit) {
     onMouseClickedEditMode();
  }
}

void onMouseClickedEditMode(){
  for (var i = 0; i < totalNpcs; i++){
    final npc = npcs[i];
    final distance = getDistanceFromMouse(npc);
    if (distance < 100){
      editorSelectedObject.value = npc;
      return;
    }
  }
  mouseRaycast(edit.selectBlock);
}









