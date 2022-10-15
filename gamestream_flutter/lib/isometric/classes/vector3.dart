import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:lemon_math/library.dart';

class Vector3 with Position {
  late double z;

  /// remove
  int get indexZ => z ~/ tileSizeHalf;
  /// remove
  int get indexRow => x ~/ tileSize;
  /// remove
  int get indexColumn => y ~/ tileSize;
  /// remove
  int get nodeIndex => getGridNodeIndexXYZ(x, y, z);
  double get renderOrder => x + y;
  /// remove
  double get renderX => (x - y) * 0.5;
  /// remove
  double get renderY => ((y + x) * 0.5) - z;
  // int get renderColor => colorShades[shade];
  /// remove
  void set indexZ(int value){
    z = value * tileSizeHalf;
  }
  /// remove
  void set indexRow(int value){
    x = value * tileSize;
  }
  /// remove
  void set indexColumn(int value){
    y = value * tileSize;
  }
  /// remove
  bool get outOfBounds =>
     z < 0                ||
     x < 0                ||
     y < 0                ||
     x > GameState.nodesLengthRow    ||
     y > GameState.nodesLengthColumn ||
     z >= GameState.nodesLengthZ     ;

  int getGridDistance(int z, int row, int column){
    var distance = (z - indexZ).abs();
    final distanceRow = (row - indexRow).abs();
    final distanceColumn = (column - indexColumn).abs();
    if (distanceRow > distance){
      distance = distanceRow;
    }
    if (distanceColumn > distance){
      return distanceColumn;
    }
    return distance;
  }

  Vector3() {
    this.x = 0;
    this.y = 0;
    this.z = 0;
  }

  @override
  String toString(){
    return 'x: ${x.toInt()}, y: ${y.toInt()}, z: ${z.toInt()}';
  }

  double distance3(double x, double y, double z){
    return sqrt(_sq(this.x - x) + _sq(this.y - y) + _sq(this.z - z));
  }

  double distanceFrom(Vector3 that){
    return distance3(that.x, that.y, that.z);
  }

  double _sq(double value){
    return value * value;
  }

  double get magnitude {
    return sqrt((x * x) + (y * y) + (z * z));
  }

}
