import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/rects.dart';
import 'package:lemon_engine/engine.dart';

Tile getTileAt(double x, double y){
  double pX = projectedToWorldX(x, y);
  double pY = projectedToWorldY(x, y);
  int column = pX ~/ tileSize;
  int row = pY ~/ tileSize;
  return getTile(row, column);
}

Tile get tileAtMouse => getTileAt(mouseWorldX, mouseWorldY);

bool get boundaryAtMouse => tileAtMouse == Tile.Boundary;

int getRow(double x, double y){
  return projectedToWorldY(x, y) ~/ tileSize;
}

int getColumn(double x, double y){
  return projectedToWorldX(x, y) ~/ tileSize;
}