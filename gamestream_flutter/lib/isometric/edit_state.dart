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

  void setBlockType(int value){
    if (grid[z][row][column] != value){
      return sendClientRequestSetBlock(edit.row, edit.column, edit.z, value);
    }
    for (var z = 1; z < edit.z; z++){
      if (GridNodeType.isStairs(value)){
        sendClientRequestSetBlock(edit.row, edit.column, z, GridNodeType.Bricks);
      } else {
        sendClientRequestSetBlock(edit.row, edit.column, z, value);
      }
    }
  }
}
