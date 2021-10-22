
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/state/getTileAt.dart';

bool isWalkable(double x, double y){
  Tile tile = getTileAt(x, y);
  if (tile == Tile.Boundary) return false;
  if (isWater(tile)) return false;
  if (isBlock(tile)) return false;
  return true;
}