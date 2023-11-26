


import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

import '../../network/send_client_request.dart';

class EditorActions {

  int get row => edit.row.value;
  int get column => edit.column.value;
  int get z => edit.z.value;

  void increaseCanvasSizeZ(){
    sendClientRequestSetCanvasSize(gridTotalZ + 1, gridTotalRows, gridTotalColumns);
  }

  void elevate(){
    // final r = edit.row.value;
    // final c = edit.column.value;
    for (var z = gridTotalZ - 2; z >= 0; z--) {
      // sendClientRequestSetBlock(r, c, z + 1, grid[z][r][c]);
    }
  }

  void raise(){
    edit.selectPlayerIfPlayerMode();
      // if (GridNodeType.isRainOrEmpty(edit.selectedType) ||
      //     GridNodeType.isGrassSlope(edit.selectedType) ||
      //     GridNodeType.isTree(edit.selectedType) ||
      //     edit.selectedType == GridNodeType.Grass_Long){
      //    edit.paintGrass();
      // }
      edit.paintSlope(row, column, z);
        // edit.paintIfEmpty(row - 1, column, z, GridNodeType.Grass_Slope_South);
        // edit.paintIfEmpty(row - 1, column - 1, z, GridNodeType.Grass_Slope_Top);
        // edit.paintIfEmpty(row + 1, column, z, GridNodeType.Grass_Slope_North);
        // edit.paintIfEmpty(row - 1, column + 1, z, GridNodeType.Grass_Slope_Left);
        // edit.paintIfEmpty(row, column - 1, z, GridNodeType.Grass_Slope_West);
        // edit.paintIfEmpty(row + 1, column + 1, z, GridNodeType.Grass_Slope_Bottom);
        // edit.paintIfEmpty(row, column + 1, z, GridNodeType.Grass_Slope_East);
        // edit.paintIfEmpty(row + 1, column - 1, z, GridNodeType.Grass_Slope_Right);
  }

  void lower(){
    // final r = edit.row.value;
    // final c = edit.column.value;
    // for (var z = 1 ; z < gridTotalZ; z++) {
    //   sendClientRequestSetBlock(r, c, z, grid[z + 1][r][c]);
    // }
    // sendClientRequestSetBlock(r, c, gridTotalZ -1, GridNodeType.Empty);
  }

  void clear(){
    for (var z = 1 ; z < gridTotalZ; z++) {
      sendClientRequestSetBlock(row, column, z, GridNodeType.Empty);
    }
    sendClientRequestSetBlock(row, column, 0, edit.paintType.value);
  }
}

