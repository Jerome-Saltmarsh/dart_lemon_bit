
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

double get mouseGridX => convertWorldToGridX(mouseWorldX, mouseWorldY) + player.z;
double get mouseGridY => convertWorldToGridY(mouseWorldX, mouseWorldY) + player.z;

// int getGridRowAt(double x, double y, double z) {
//   return (y - z - x) ~/ tileSize;;
// }
//
// void getTileAtMouse(){
//
// }

double get mousePlayerAngle {
   final adjacent = player.x - mouseGridX;
   final opposite = player.y - mouseGridY - player.z;
   return getAngle(adjacent, opposite);
}

int get mouseColumn {
  return mouseGridX ~/ tileSize;
}

int get mouseRow {
  return mouseGridY ~/ tileSize;
}

double get mouseRowPercentage {
  return (convertWorldToGridY(mouseWorldX, mouseWorldY) / tileSize) % 1.0;
}
