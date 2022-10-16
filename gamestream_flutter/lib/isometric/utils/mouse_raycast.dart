import 'package:bleed_common/node_type.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:lemon_engine/engine.dart';

void mouseRaycast(Function(int z, int row, int column) callback){
  var z = Game.nodesTotalZ - 1;
  while (z >= 0){
    final row = convertWorldToRow(mouseWorldX, mouseWorldY, z * tileHeight);
    final column = convertWorldToColumn(mouseWorldX, mouseWorldY, z * tileHeight);
    if (row < 0) break;
    if (column < 0) break;
    if (row >= Game.nodesTotalRows) break;
    if (column >= Game.nodesTotalColumns) break;
    if (z >= Game.nodesTotalZ) break;
    final index = getNodeIndexZRC(z, row, column);
    if (Game.nodesType[index] == NodeType.Empty
        ||
        NodeType.isRain(Game.nodesType[index])
    ) {
      z--;
      continue;
    }
    if (!Game.nodesVisible[index]) {
      z--;
      continue;
    }
    callback(z, row, column);
    return;
  }
}
