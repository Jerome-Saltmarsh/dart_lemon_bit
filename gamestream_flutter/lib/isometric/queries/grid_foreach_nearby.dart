


import 'dart:math';

import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';

int getClosestByType({required int radius, required int type}){
  final minRow = max(Game.player.indexRow - radius, 0);
  final maxRow = min(Game.player.indexRow + radius, Game.nodesTotalRows - 1);
  final minColumn = max(Game.player.indexColumn - radius, 0);
  final maxColumn = min(Game.player.indexColumn + radius, Game.nodesTotalColumns - 1);
  final minZ = max(Game.player.indexZ - radius, 0);
  final maxZ = min(Game.player.indexZ + radius, Game.nodesTotalZ - 1);
  var closest = 99999;
  for (var z = minZ; z <= maxZ; z++){
    for (var row = minRow; row <= maxRow; row++){
      for (var column = minColumn; column <= maxColumn; column++){
        if (gridNodeZRCType(z, row, column) != type) continue;
         final distance = Game.player.getGridDistance(z, row, column);
         if (distance > closest) continue;
         closest = distance;
      }
    }
  }
  return closest;
}