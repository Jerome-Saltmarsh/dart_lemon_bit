import 'package:bleed_common/library.dart';
import 'package:lemon_engine/engine.dart';

void cameraSetPositionGrid(int row, int column, int z){
  cameraSetPosition(row * tileSize, column * tileSize, z * tileHeight);
}

void cameraSetPosition(double x, double y, double z){
  final renderX = (x - y) * 0.5;
  final renderY = ((y + x) * 0.5) - z;
  Engine.cameraCenter(renderX, renderY);
}