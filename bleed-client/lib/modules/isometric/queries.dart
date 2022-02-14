import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:lemon_engine/engine.dart';

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
    return getTile(
        projectedToWorldY(x, y) ~/ tileSize,
        projectedToWorldY(x, y) ~/ tileSize,
    );
  }

  bool tileIsWalkable(double x, double y){
    final tile = getTileAt(x, y);
    if (tile == Tile.Boundary) return false;
    if (tile.isWater) return false;
    return true;
  }

  bool isWaterAt(double x, double y){
    return getTileAt(x, y).isWater;
  }

  bool environmentObjectOnScreenScreen(EnvironmentObject environmentObject) {
    if (environmentObject.top > engine.screen.bottom) return false;
    if (environmentObject.right < engine.screen.left) return false;
    if (environmentObject.left > engine.screen.right) return false;
    if (environmentObject.bottom < engine.screen.top) return false;
    return true;
  }

  double mapWeaponAimLength(WeaponType weapon) {
    switch (weapon) {
      case WeaponType.Unarmed:
        return 20;
      case WeaponType.HandGun:
        return 20;
      case WeaponType.Shotgun:
        return 25;
      case WeaponType.SniperRifle:
        return 150;
      case WeaponType.AssaultRifle:
        return 50;
      default:
        return 10;
    }
  }
}