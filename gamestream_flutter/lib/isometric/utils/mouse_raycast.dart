import 'package:bleed_common/grid_node_type.dart';
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
    if (grid[z][row][column] == GridNodeType.Empty) {
      z--;
      continue;
    }
    callback(z, row, column);
    return;
  }
}

void raycastXYZ(double x, double y, double z, Function(int z, int row, int column) callback){
  var zIndex = gridTotalZ - 1;
  while (zIndex >= 0){
    final row = convertWorldToRow(x, y, z);
    final column = convertWorldToColumn(x, y, z);
    if (row < 0) break;
    if (column < 0) break;
    if (row >= gridTotalRows) break;
    if (column >= gridTotalColumns) break;
    if (zIndex >= gridTotalZ) break;
    if (grid[zIndex][row][column] == GridNodeType.Empty) {
      zIndex--;
      continue;
    }
    callback(zIndex, row, column);
    return;
  }
}