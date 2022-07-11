import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/queries/get_grid_type.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:lemon_watch/watch.dart';

import 'grid.dart';

final edit = EditState();

class EditState {
  var row = Watch(0);
  var column = Watch(0);
  var z = Watch(1);
  final type = Watch(GridNodeType.Bricks);
  final paintType = Watch(GridNodeType.Bricks);
  final controlsVisibleWeather = Watch(true);

  void actionToggleControlsVisibleWeather(){
    controlsVisibleWeather.value = !controlsVisibleWeather.value;
  }

  void selectBlock(int z, int row, int column){
    this.row.value = row;
    this.column.value = column;
    this.z.value = z;
    refreshType();
  }

  void refreshType(){
    type.value = gridGetType(z.value, row.value, column.value);
  }

  void deleteBlock(){
      setCurrentBlock(z.value > 0 ? GridNodeType.Empty : GridNodeType.Grass);
  }

  void setBlockType(int value){
    if (grid[z.value][row.value][column.value] != value){
      return setCurrentBlock(value);
    }
    for (var zIndex = 1; zIndex < z.value; zIndex++){
      if (GridNodeType.isStairs(value)){
        sendClientRequestSetBlock(row.value, column.value, zIndex, GridNodeType.Bricks);
      } else {
        sendClientRequestSetBlock(row.value, column.value, zIndex, value);
      }
    }
  }

  void setCurrentBlock(int value){
    if (value != GridNodeType.Empty) {
      paintType.value = value;
    }
    return sendClientRequestSetBlock(row.value, column.value, z.value, value);
  }
}

void actionEditSetShortcutType(){
   edit.setCurrentBlock(edit.paintType.value);
}

void editZIncrease(){
   if (edit.z.value >= gridTotalZ) return;
   edit.z.value++;
}

void editZDecrease(){
  if (edit.z.value <= 0) return;
  edit.z.value--;
}