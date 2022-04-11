import 'package:bleed_common/Tile.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:lemon_engine/engine.dart';

import 'state.dart';
import 'utilities.dart';

class IsometricQueries {
  final IsometricState state;

  final _screen = engine.screen;

  IsometricQueries(this.state);

  int get tileAtMouse => state.getTileAt(mouseWorldX, mouseWorldY);

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

  bool environmentObjectOnScreenScreen(EnvironmentObject environmentObject) {
    if (environmentObject.top > _screen.bottom) return false;
    if (environmentObject.right < _screen.left) return false;
    if (environmentObject.left > _screen.right) return false;
    if (environmentObject.bottom < _screen.top) return false;
    return true;
  }
}