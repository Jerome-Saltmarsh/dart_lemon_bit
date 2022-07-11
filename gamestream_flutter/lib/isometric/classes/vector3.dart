import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:lemon_math/library.dart';

class Vector3 with Position {
  late double z;

  int get indexZ => z ~/ tileSizeHalf;
  int get indexRow => x ~/ tileSize;
  int get indexColumn => y ~/ tileSize;
  double get renderOrder => x + y;
  int get tile => grid[indexZ][indexRow][indexColumn];
  int get tileSafe => getGridTypeAtXYZ(x, y, z);
  int get tileBelow => indexZ == 0 ? GridNodeType.Boundary : grid[indexZ - 1][indexRow][indexColumn];
  int get tileAbove => indexZ < gridTotalZ - 1 ? GridNodeType.Boundary : grid[indexZ + 1][indexRow][indexColumn];
  int get shade => gridLightDynamic[z >= tileSizeHalf ? indexZ - 1 : 0][indexRow][indexColumn];
  int get wind => gridWind[z >= tileSizeHalf ? indexZ - 1 : 0][indexRow][indexColumn];

  double get renderX => (x - y) * 0.5;
  double get renderY => ((y + x) * 0.5) - z;
  int get renderColor => colorShades[shade];

  void set indexZ(int value){
    z = value * tileSizeHalf;
  }

  void set indexRow(int value){
    x = value * tileSize;
  }

  void set indexColumn(int value){
    y = value * tileSize;
  }

  bool get outOfBounds =>
     z < 0 ||
     x < 0 ||
     x > gridRowLength ||
     y < 0 ||
     y > gridColumnLength ||
     z >= tileHeight ;

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

  double _sq(double value){
    return value * value;
  }
}
