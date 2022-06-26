import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:lemon_math/library.dart';

class Vector3 with Position {
  late double z;

  int get indexZ => z ~/ tileSizeHalf;
  int get indexRow => x ~/ tileSize;
  int get indexColumn => y ~/ tileSize;
  double get renderOrder => x + y;
  int get tile => grid[indexZ][indexRow][indexColumn];
  int get shade => gridLightDynamic[z >= tileSizeHalf ? indexZ - 1 : 0][indexRow][indexColumn];

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

  bool get outOfBounds {
    return z < 0 || x < 0 || x > gridRowLength || y < 0 || y > gridColumnLength;
  }

  Vector3(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  @override
  String toString(){
    return 'x: ${x.toInt()}, y: ${y.toInt()}, z: ${z.toInt()}';
  }
}
