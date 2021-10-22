import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/rects.dart';

Tile getTileAt(double x, double y){
  double pX = projectedToWorldX(x, y);
  double pY = projectedToWorldY(x, y);
  int column = pX ~/ tileSize;
  int row = pY ~/ tileSize;
  return getTile(row, column);
}