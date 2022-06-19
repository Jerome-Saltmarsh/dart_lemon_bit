import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/client_request_sender.dart';
import 'package:lemon_watch/watch.dart';

import 'grid.dart';

final edit = EditState();

class EditState {
  var row = Watch(0);
  var column = Watch(0);
  var z = Watch(0);

  final type = Watch(GridNodeType.Bricks);

  void refreshType(){
    type.value = grid[z.value][row.value][column.value];
  }

  void setBlockType(int value){
    if (grid[z.value][row.value][column.value] != value){
      return sendClientRequestSetBlock(row.value, column.value, z.value, value);
    }
    for (var z = 1; z < z; z++){
      if (GridNodeType.isStairs(value)){
        sendClientRequestSetBlock(row.value, column.value, z, GridNodeType.Bricks);
      } else {
        sendClientRequestSetBlock(row.value, column.value, z, value);
      }
    }
  }
}

void editZIncrease(){
   if (edit.z.value >= gridTotalZ) return;
   edit.z.value++;
}

void editZDecrease(){
  if (edit.z.value <= 0) return;
  edit.z.value--;
}