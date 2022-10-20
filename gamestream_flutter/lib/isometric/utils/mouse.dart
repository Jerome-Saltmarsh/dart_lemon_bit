
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

double get mouseGridX => convertWorldToGridX(Engine.mouseWorldX, Engine.mouseWorldY) + GameState.player.z;
double get mouseGridY => convertWorldToGridY(Engine.mouseWorldX, Engine.mouseWorldY) + GameState.player.z;

double get mouseGridXStandard => convertWorldToGridX(Engine.mouseWorldX, Engine.mouseWorldY);
double get mouseGridYStandard => convertWorldToGridY(Engine.mouseWorldX, Engine.mouseWorldY);

double get mousePlayerAngle {
   final adjacent = GameState.player.x - mouseGridX;
   final opposite = GameState.player.y - mouseGridY - GameState.player.z;
   return getAngle(adjacent, opposite);
}

int get mouseColumn {
  return mouseGridX ~/ tileSize;
}

int get mouseRow {
  return mouseGridY ~/ tileSize;
}

int getMouseRow (int z){
  return (convertWorldToGridX(Engine.mouseWorldX, Engine.mouseWorldY) + (z * tileHeight)) ~/ tileSize;
}

int getMouseColumn (int z) {
  return (convertWorldToGridY(Engine.mouseWorldX, Engine.mouseWorldY) + (z * tileHeight)) ~/ tileSize;
}

double get mouseRowPercentage {
  return (convertWorldToGridY(Engine.mouseWorldX, Engine.mouseWorldY) / tileSize) % 1.0;
}
