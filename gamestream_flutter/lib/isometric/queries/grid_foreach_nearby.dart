


import 'dart:math';

import 'package:gamestream_flutter/library.dart';

int getClosestByType({required int radius, required int type}){
  final minRow = max(GameState.player.indexRow - radius, 0);
  final maxRow = min(GameState.player.indexRow + radius, GameState.nodesTotalRows - 1);
  final minColumn = max(GameState.player.indexColumn - radius, 0);
  final maxColumn = min(GameState.player.indexColumn + radius, GameState.nodesTotalColumns - 1);
  final minZ = max(GameState.player.indexZ - radius, 0);
  final maxZ = min(GameState.player.indexZ + radius, GameState.nodesTotalZ - 1);
  var closest = 99999;
  for (var z = minZ; z <= maxZ; z++){
    for (var row = minRow; row <= maxRow; row++){
      for (var column = minColumn; column <= maxColumn; column++){
        if (GameQueries.gridNodeZRCType(z, row, column) != type) continue;
         final distance = GameState.player.getGridDistance(z, row, column);
         if (distance > closest) continue;
         closest = distance;
      }
    }
  }
  return closest;
}