
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

double get mouseGridX => convertWorldToGridX(mouseWorldX, mouseWorldY) + player.z;
double get mouseGridY => convertWorldToGridY(mouseWorldX, mouseWorldY) + player.z;

double get mouseGridXStandard => convertWorldToGridX(mouseWorldX, mouseWorldY);
double get mouseGridYStandard => convertWorldToGridY(mouseWorldX, mouseWorldY);

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

int getMouseRow (int z){
  return (convertWorldToGridX(mouseWorldX, mouseWorldY) + (z * tileHeight)) ~/ tileSize;
}

int getMouseColumn (int z) {
  return (convertWorldToGridY(mouseWorldX, mouseWorldY) + (z * tileHeight)) ~/ tileSize;
}

double get mouseRowPercentage {
  return (convertWorldToGridY(mouseWorldX, mouseWorldY) / tileSize) % 1.0;
}
