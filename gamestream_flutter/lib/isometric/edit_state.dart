import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/client_request_sender.dart';
import 'package:lemon_watch/watch.dart';

import 'grid.dart';

final edit = EditState();

class EditState {
  var row = 0;
  var column = 0;
  var z = 0;

  final type = Watch(GridNodeType.Bricks);

  void refreshType(){
    type.value = grid[z][row][column];
  }

  void setBlockType(int value){
    if (grid[z][row][column] != value){
      return sendClientRequestSetBlock(row, column, z, value);
    }
    for (var z = 1; z < edit.z; z++){
      if (GridNodeType.isStairs(value)){
        sendClientRequestSetBlock(row, column, z, GridNodeType.Bricks);
      } else {
        sendClientRequestSetBlock(row, column, z, value);
      }
    }
  }
}
