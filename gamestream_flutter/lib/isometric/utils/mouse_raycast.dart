import 'package:bleed_common/node_type.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:lemon_engine/engine.dart';

void mouseRaycast(Function(int z, int row, int column) callback){
  var z = GameState.nodesTotalZ - 1;
  while (z >= 0){
    final row = convertWorldToRow(mouseWorldX, mouseWorldY, z * tileHeight);
    final column = convertWorldToColumn(mouseWorldX, mouseWorldY, z * tileHeight);
    if (row < 0) break;
    if (column < 0) break;
    if (row >= GameState.nodesTotalRows) break;
    if (column >= GameState.nodesTotalColumns) break;
    if (z >= GameState.nodesTotalZ) break;
    final index = getNodeIndexZRC(z, row, column);
    if (GameState.nodesType[index] == NodeType.Empty
        ||
        NodeType.isRain(GameState.nodesType[index])
    ) {
      z--;
      continue;
    }
    if (!GameState.nodesVisible[index]) {
      z--;
      continue;
    }
    callback(z, row, column);
    return;
  }
}
