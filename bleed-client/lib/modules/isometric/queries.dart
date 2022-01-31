import 'package:bleed_client/common/Tile.dart';
import 'package:lemon_engine/engine.dart';

import '../modules.dart';
import 'state.dart';
import 'utilities.dart';

class IsometricQueries {
  final IsometricState state;
  IsometricQueries(this.state);

  Tile get tileAtMouse => getTileAt(mouseWorldX, mouseWorldY);

  Tile getTile(int row, int column){
    if (outOfBounds(row, column)) return Tile.Boundary;
    return state.tiles[row][column];
  }

  bool outOfBounds(int row, int column){
    if (row < 0) return true;
    if (column < 0) return true;
    if (row >= state.totalRowsInt) return true;
    if (column >= state.totalColumnsInt) return true;
    return false;
  }

  bool mouseOutOfBounds(){
    return outOfBounds(mouseRow, mouseColumn);
  }

  Tile getTileAt(double x, double y){
    double pX = projectedToWorldX(x, y);
    double pY = projectedToWorldY(x, y);
    int column = pX ~/ tileSize;
    int row = pY ~/ tileSize;
    return getTile(row, column);
  }

  bool tileIsWalkable(double x, double y){
    Tile tile = getTileAt(x, y);
    if (tile == Tile.Boundary) return false;
    if (isWater(tile)) return false;
    if (isBlock(tile)) return false;
    return true;
  }

  bool isWaterAt(double x, double y){
    return isWater(getTileAt(x, y));
  }
}