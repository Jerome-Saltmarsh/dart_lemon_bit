import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_editor_column_changed.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_editor_z_changed.dart';
import 'package:gamestream_flutter/isometric/queries/get_grid_type.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:lemon_watch/watch.dart';

import 'editor/events/on_editor_row_changed.dart';
import 'grid.dart';
import 'player.dart';

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

  void fill(){
    for (var zIndex = 0; zIndex <= z.value; zIndex++){
      sendClientRequestSetBlock(row.value, column.value, zIndex, paintType.value);
    }
  }

  void paintIfEmpty(int row, int column, int z, int type){
    final t = grid[z][row][column];
    if (!GridNodeType.isRainOrEmpty(t) && t != GridNodeType.Grass_Long) return;
    sendClientRequestSetBlock(row, column, z, type);
  }

  void paintTorch(){
    paint(GridNodeType.Torch);
  }

  void paintTree(){
    sendClientRequestSetBlock(row.value, column.value, z.value, GridNodeType.Tree_Bottom);
    sendClientRequestSetBlock(row.value, column.value, z.value + 1, GridNodeType.Tree_Top);
  }

  void paintLongGrass(){
    paint(GridNodeType.Grass_Long);
  }

  void paintTreeAtPlayer(){
    sendClientRequestSetBlock(player.indexRow, player.indexColumn, player.indexZ, GridNodeType.Tree_Bottom);
    sendClientRequestSetBlock(player.indexRow, player.indexColumn, player.indexZ + 1, GridNodeType.Tree_Top);
  }

  void paintAtPlayerLongGrass(){
    sendClientRequestSetBlock(player.indexRow, player.indexColumn, player.indexZ, GridNodeType.Grass_Long);
  }

  void paintBricks(){
    paint(GridNodeType.Bricks);
  }

  void paintGrass(){
    paint(GridNodeType.Grass);
  }

  void paintWater(){
    paint(GridNodeType.Water);
  }

  void paintFloorBricks(){
     for (var row = 0; row < gridTotalRows; row++){
        for (var column = 0; column < gridTotalColumns; column++){
          sendClientRequestSetBlock(row, column, 0, GridNodeType.Bricks);
        }
     }
  }

  void selectBlock(int z, int row, int column){
    this.row.value = row;
    this.column.value = column;
    this.z.value = z;
  }

  void selectPlayerBlock(){
    row.value = player.indexRow;
    column.value = player.indexColumn;
    z.value = player.indexZ;
  }

  void refreshType(){
    type.value = gridGetType(z.value, row.value, column.value);
  }

  void delete(){
    deleteIfTree();
    sendClientRequestSetBlock(row.value, column.value, z.value, GridNodeType.Empty);
  }

  void deleteIfTree(){
    if (currentType == GridNodeType.Tree_Bottom){
      if (z.value < gridTotalZ - 1){
        if (grid[z.value + 1][row.value][column.value] == GridNodeType.Tree_Top){
          sendClientRequestSetBlock(row.value, column.value, z.value + 1, GridNodeType.Empty);
        }
      }
    }
    if (currentType == GridNodeType.Tree_Top){
      if (z.value > 0){
        if (grid[z.value - 1][row.value][column.value] == GridNodeType.Tree_Bottom){
          sendClientRequestSetBlock(row.value, column.value, z.value - 1, GridNodeType.Empty);
        }
      }
    }
  }

  void selectPaintType(){
     paintType.value = currentType;
  }

  void paint([int? value]){
    if (value == GridNodeType.Empty){
       return delete();
    }

    if (value != null) {
      paintType.value = value;
    }

    deleteIfTree();

    if (currentType != paintType.value){
      return sendClientRequestSetBlock(row.value, column.value, z.value, paintType.value);
    }

    if (GridNodeType.isGrassSlope(currentType)){
      for (var zIndex = 0; zIndex < z.value; zIndex++){
        sendClientRequestSetBlock(row.value, column.value, zIndex, GridNodeType.Grass);
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