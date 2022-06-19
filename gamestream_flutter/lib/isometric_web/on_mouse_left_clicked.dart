
import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:lemon_engine/engine.dart';

void onMouseLeftClicked(){
  print("onMouseLeftClicked()");

  if (playModeEdit){
    var row = convertWorldToRow(mouseWorldX, mouseWorldY, 24);
    var column = convertWorldToColumn(mouseWorldX, mouseWorldY, 24);
    for (var z = 0; z < gridTotalZ; z ++){
      row++;
      column ++;
      if (grid[z][row][column] == GridNodeType.Empty) continue;
      edit.row = row;
      edit.column = column;
      edit.z = z;
    }
    edit.refreshType();
  }
}