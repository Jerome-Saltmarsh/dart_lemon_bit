import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/queries/set_grid_type.dart';

void apiGridActionRainOn(){
  for (var row = 0; row < gridTotalRows; row++) {
    for (var column = 0; column < gridTotalColumns; column++) {
      for (var z = gridTotalZ - 1; z >= 0; z--) {
        final type = grid[z][row][column];
        if (!isEmpty(type)) {
          setGridType(z + 1, row, column, GridNodeType.Rain_Landing);
          setGridType(z + 2, row, column, GridNodeType.Rain_Falling);
          break;
        } else {
          if (column == 0 || !isEmpty(grid[z][row][column - 1])){
            grid[z][row][column] = GridNodeType.Rain_Falling;
          } else
          if (row == 0 || !isEmpty(grid[z][row - 1][column])){
            grid[z][row][column] = GridNodeType.Rain_Falling;
          }
        }
      }
    }
  }
}