


import 'dart:math';

import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/player.dart';

int getClosestByType({required int radius, required int type}){
  final minRow = max(player.indexRow - radius, 0);
  final maxRow = min(player.indexRow + radius, nodesTotalRows - 1);
  final minColumn = max(player.indexColumn - radius, 0);
  final maxColumn = min(player.indexColumn + radius, nodesTotalColumns - 1);
  final minZ = max(player.indexZ - radius, 0);
  final maxZ = min(player.indexZ + radius, nodesTotalZ - 1);
  var closest = 99999;
  for (var z = minZ; z <= maxZ; z++){
    for (var row = minRow; row <= maxRow; row++){
      for (var column = minColumn; column <= maxColumn; column++){
        if (gridNodeZRCType(z, row, column) != type) continue;
         final distance = player.getGridDistance(z, row, column);
         if (distance > closest) continue;
         closest = distance;
      }
    }
  }
  return closest;
}