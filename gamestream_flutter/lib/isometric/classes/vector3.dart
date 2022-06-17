import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:lemon_math/library.dart';

class Vector3 with Position {
  late double z;

  int get indexZ => z ~/ tileSizeHalf;
  int get indexRow => x ~/ tileSize;
  int get indexColumn => y ~/ tileSize;
  double get renderOrder => x + y;
  int get tile => grid[indexZ][indexRow][indexColumn];
  int get shade => gridLightDynamic[indexZ][indexRow][indexColumn];

  double get renderX => (x - y) * 0.5;
  double get renderY => ((y + x) * 0.5) - z;

  Vector3(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}
