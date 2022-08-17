import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:lemon_engine/engine.dart';

void mouseRaycast(Function(int z, int row, int column) callback){
  var z = gridTotalZ - 1;
  while (z >= 0){
    final row = convertWorldToRow(mouseWorldX, mouseWorldY, z * tileHeight);
    final column = convertWorldToColumn(mouseWorldX, mouseWorldY, z * tileHeight);
    if (row < 0) break;
    if (column < 0) break;
    if (row >= gridTotalRows) break;
    if (column >= gridTotalColumns) break;
    if (z >= gridTotalZ) break;
    if (grid[z][row][column].isEmpty) {
      z--;
      continue;
    }
    callback(z, row, column);
    return;
  }
}
