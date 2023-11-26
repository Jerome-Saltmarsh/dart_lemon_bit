


import 'dart:math';

import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/player.dart';

int getClosestByType({required int radius, required int type}){
  final minRow = max(player.indexRow - radius, 0);
  final maxRow = min(player.indexRow + radius, gridTotalRows - 1);
  final minColumn = max(player.indexColumn - radius, 0);
  final maxColumn = min(player.indexColumn + radius, gridTotalColumns - 1);
  final minZ = max(player.indexZ - radius, 0);
  final maxZ = min(player.indexZ + radius, gridTotalZ - 1);

  var closest = 99999;
  for (var z = minZ; z <= maxZ; z++){
    final gridZ = grid[z];
    for (var row = minRow; row <= maxRow; row++){
      final gridZRow = gridZ[row];
      for (var column = minColumn; column <= maxColumn; column++){
         if (type != gridZRow[column]) continue;
         final distance = player.getGridDistance(z, row, column);
         if (distance > closest) continue;
         closest = distance;
      }
    }
  }
  return closest;
}