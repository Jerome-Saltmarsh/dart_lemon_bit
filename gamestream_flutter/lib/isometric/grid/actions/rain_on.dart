import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';
import 'package:gamestream_flutter/isometric/queries/set_grid_type.dart';

void rainOn(){
  for (var row = 0; row < gridTotalRows; row++) {
    for (var column = 0; column < gridTotalColumns; column++) {
      for (var z = gridTotalZ - 1; z >= 0; z--) {
        final index = getGridNodeIndexZRC(z, row, column);
        final type = nodesType[index];
        if (type != NodeType.Empty) {
          if (type == NodeType.Water || nodesOrientation[index] == NodeOrientation.Solid) {
            setGridType(z + 1, row, column, NodeType.Rain_Landing);
          }
          setGridType(z + 2, row, column, NodeType.Rain_Falling);
          break;
        }

        if (
            column == 0 ||
            row == 0 ||
            !gridNodeZRCTypeRainOrEmpty(z, row - 1, column) ||
            !gridNodeZRCTypeRainOrEmpty(z, row, column - 1)
        ){
          setGridType(z, row, column, NodeType.Rain_Falling);
        }
      }
    }
  }
}