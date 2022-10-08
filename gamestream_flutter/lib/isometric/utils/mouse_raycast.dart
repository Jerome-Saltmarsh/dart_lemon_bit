import 'package:bleed_common/node_type.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:lemon_engine/engine.dart';

void mouseRaycast(Function(int z, int row, int column) callback){
  var z = nodesTotalZ - 1;
  while (z >= 0){
    final row = convertWorldToRow(mouseWorldX, mouseWorldY, z * tileHeight);
    final column = convertWorldToColumn(mouseWorldX, mouseWorldY, z * tileHeight);
    if (row < 0) break;
    if (column < 0) break;
    if (row >= nodesTotalRows) break;
    if (column >= nodesTotalColumns) break;
    if (z >= nodesTotalZ) break;
    final index = getNodeIndexZRC(z, row, column);
    if (nodesType[index] == NodeType.Empty
        ||
        NodeType.isRain(nodesType[index])
    ) {
      z--;
      continue;
    }
    if (!nodesVisible[index]) {
      z--;
      continue;
    }
    callback(z, row, column);
    return;
  }
}
