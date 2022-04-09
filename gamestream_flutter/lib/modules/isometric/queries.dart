import 'package:bleed_common/Tile.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:lemon_engine/engine.dart';

import 'state.dart';
import 'utilities.dart';

class IsometricQueries {
  final IsometricState state;

  final _screen = engine.screen;

  IsometricQueries(this.state);

  int get tileAtMouse => getTileAt(mouseWorldX, mouseWorldY);

  int getTile(int row, int column){
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

  int getTileAt(double x, double y){
    return getTile(getRow(x, y), getColumn(x, y));
  }

  bool tileIsWalkable(double x, double y){
    final tile = getTileAt(x, y);
    if (tile == Tile.Boundary) return false;
    if (tile == Tile.Water) return false;
    return true;
  }

  bool environmentObjectOnScreenScreen(EnvironmentObject environmentObject) {
    if (environmentObject.top > _screen.bottom) return false;
    if (environmentObject.right < _screen.left) return false;
    if (environmentObject.left > _screen.right) return false;
    if (environmentObject.bottom < _screen.top) return false;
    return true;
  }
}