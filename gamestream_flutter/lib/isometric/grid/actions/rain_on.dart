import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/queries/set_grid_type.dart';

void rainOn(){
  for (var row = 0; row < GameState.nodesTotalRows; row++) {
    for (var column = 0; column < GameState.nodesTotalColumns; column++) {
      for (var z = GameState.nodesTotalZ - 1; z >= 0; z--) {

        final index = GameState.getNodeIndexZRC(z, row, column);
        final type = GameState.nodesType[index];
        if (type != NodeType.Empty) {
          if (type == NodeType.Water || GameState.nodesOrientation[index] == NodeOrientation.Solid) {
            setNodeType(z + 1, row, column, NodeType.Rain_Landing);
          }
          setNodeType(z + 2, row, column, NodeType.Rain_Falling);
          break;
        }

        if (
        column == 0 ||
            row == 0 ||
            !gridNodeZRCTypeRainOrEmpty(z, row - 1, column) ||
            !gridNodeZRCTypeRainOrEmpty(z, row, column - 1)
        ){
          setNodeType(z, row, column, NodeType.Rain_Falling);
        }
      }
    }
  }
}