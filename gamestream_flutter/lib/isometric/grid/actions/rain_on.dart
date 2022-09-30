import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';
import 'package:gamestream_flutter/isometric/queries/set_grid_type.dart';

void rainOn(){
  for (var row = 0; row < gridTotalRows; row++) {
    for (var column = 0; column < gridTotalColumns; column++) {
      for (var z = gridTotalZ - 1; z >= 0; z--) {
        final index = gridNodeIndexZRC(z, row, column);
        final node = gridNodeTypes[index];
        if (node != NodeType.Empty) {
          if (NodeType.isRainable(node)) {
            setGridType(z + 1, row, column, NodeType.Rain_Landing);
          }
          setGridType(z + 2, row, column, NodeType.Rain_Falling);
          break;
        } else {
          if (column == 0 || !gridNodeZRCTypeEmpty(z, row, column - 1)){
            setGridType(z, row, column, NodeType.Rain_Falling);
          } else
          if (row == 0 || gridNodeZRCTypeEmpty(z, row - 1, column)){
            setGridType(z, row, column, NodeType.Rain_Falling);
          }
        }
      }
    }
  }
}