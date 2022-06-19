
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/utils/mouse_raycast.dart';

void onMouseLeftClicked(){
  print("onMouseLeftClicked()");

  if (playModeEdit){
    mouseRaycast((int z, int row, int column){
      edit.row = row;
      edit.column = column;
      edit.z = z;
    });
    edit.refreshType();
  }
}

