

import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

void apiGridActionRainOff(){
  for (var z = gridTotalZ - 1; z >= 0; z--) {
    for (var row = 0; row < gridTotalRows; row++) {
      for (var column = 0; column < gridTotalColumns; column++) {
        final type = grid[z][row][column];
        if (type != GridNodeType.Rain_Falling || type != GridNodeType.Rain_Landing) continue;
        grid[z][row][column] = GridNodeType.Empty;
      }
    }
  }
}