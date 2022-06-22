
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/utils/mouse_raycast.dart';

void onMouseLeftClicked(){
  if (playModeEdit){
    mouseRaycast((int z, int row, int column){
      edit.row.value = row;
      edit.column.value = column;
      edit.z.value = z;
    });
    edit.refreshType();
  }
}

