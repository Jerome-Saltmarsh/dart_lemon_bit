
import 'package:lemon_math/library.dart';

import '../common/tile_size.dart';

class Position3 with Position {
  double z = 0;
  int get indexZ => z ~/ tileSizeHalf;
  int get indexRow => x ~/ tileSize;
  int get indexColumn => y ~/ tileSize;

  double get percentageRow => (x % tileSize) / tileSize;
  double get percentageColumn => (y % tileSize) / tileSize;
  double get percentageZ => (z % tileHeight) / tileHeight;

  double get renderX => (x - y) * 0.5;
  double get renderY => ((y + x) * 0.5) - z;

  void set indexZ(int value){
    z = value * tileSizeHalf;
  }

  void set indexRow(int value){
    x = value * tileSize;
  }

  void set indexColumn(int value){
    y = value * tileSize;
  }

  Position3 set({double? x, double? y, double? z}){
     if (x != null) this.x = x;
     if (y != null) this.y = y;
     if (z != null) this.x = z;
     return this;
  }

  // double getGridAngle(double x, double y) {
  //   return pi2 - getAngle(this.y - y, this.x - x);
  // }
}