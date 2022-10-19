import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/queries/set_grid_type.dart';

void rainOn(){
  for (var row = 0; row < Game.nodesTotalRows; row++) {
    for (var column = 0; column < Game.nodesTotalColumns; column++) {
      for (var z = Game.nodesTotalZ - 1; z >= 0; z--) {

        final index = Game.getNodeIndexZRC(z, row, column);
        final type = Game.nodesType[index];
        if (type != NodeType.Empty) {
          if (type == NodeType.Water || Game.nodesOrientation[index] == NodeOrientation.Solid) {
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