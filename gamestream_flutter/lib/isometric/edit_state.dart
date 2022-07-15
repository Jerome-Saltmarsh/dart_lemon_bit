import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_editor_column_changed.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_editor_z_changed.dart';
import 'package:gamestream_flutter/isometric/queries/get_grid_type.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:lemon_watch/watch.dart';

import 'editor/events/on_editor_row_changed.dart';
import 'grid.dart';

final edit = EditState();

class EditState {
  var row = Watch(0, clamp: (int value){
    if (value < 0) return 0;
    if (value >= gridTotalRows) return gridTotalRows - 1;
    return value;
  }, onChanged: onEditorRowChanged);
  var column = Watch(0, clamp: (int value){
    if (value < 0) return 0;
    if (value >= gridTotalColumns) return gridTotalColumns - 1;
    return value;
  },
  onChanged: onEditorColumnChanged
  );
  var z = Watch(1, clamp: (int value){
    if (value < 0) return 0;
    if (value >= gridTotalZ) return gridTotalZ - 1;
    return value;
  }, onChanged: onEditorZChanged);
  final type = Watch(GridNodeType.Bricks);
  final paintType = Watch(GridNodeType.Bricks);
  final controlsVisibleWeather = Watch(true);

  int get currentType => gridGetType(z.value, row.value, column.value);

  void actionToggleControlsVisibleWeather(){
    controlsVisibleWeather.value = !controlsVisibleWeather.value;
  }

  void selectBlock(int z, int row, int column){
    this.row.value = row;
    this.column.value = column;
    this.z.value = z;
  }

  void refreshType(){
    type.value = gridGetType(z.value, row.value, column.value);
  }

  void delete(){
    set(z.value > 0 ? GridNodeType.Empty : GridNodeType.Grass);
  }

  void paint(){
    set(edit.paintType.value);
  }

  void set(int value){
    if (value != GridNodeType.Empty) {
      paintType.value = value;
    }

    if (value == GridNodeType.Tree_Bottom || value == GridNodeType.Tree_Top){
      if (currentType == GridNodeType.Empty){
        sendClientRequestSetBlock(row.value, column.value, z.value + 1, GridNodeType.Tree_Top);
        sendClientRequestSetBlock(row.value, column.value, z.value, GridNodeType.Tree_Bottom);
        return;
      }
    }

    if (currentType != value){
      return sendClientRequestSetBlock(row.value, column.value, z.value, value);
    }

    // for (var zIndex = 1; zIndex < z.value; zIndex++){
    //   if (GridNodeType.isStairs(value)){
    //     sendClientRequestSetBlock(row.value, column.value, zIndex, GridNodeType.Bricks);
    //   } else {
    //     sendClientRequestSetBlock(row.value, column.value, zIndex, value);
    //   }
    // }
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