
import 'dart:math';

import 'package:lemon_math/library.dart';

import '../common/src/tile_size.dart';

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
  double get order => (y + x);

  void set indexZ(int value){
    z = value * tileSizeHalf;
  }

  void set indexRow(int value){
    x = value * tileSize + tileSizeHalf;
  }

  void set indexColumn(int value){
    y = value * tileSize + tileSizeHalf;
  }

  Position3 set({double? x, double? y, double? z}){
     if (x != null) this.x = x;
     if (y != null) this.y = y;
     if (z != null) this.x = z;
     return this;
  }

  bool withinRadius(Position3 position3, num radius){
    return withinDistance(position3.x, position3.y, position3.z, radius);
  }

  bool withinDistance(double x, double y, double z, num radius){
    final xDiff = (this.x - x).abs();
    if (xDiff > radius) return false;

    final yDiff = (this.y - y).abs();
    if (yDiff > radius) return false;

    final zDiff = (this.z - z).abs();
    if (zDiff > radius) return false;

    return sqrt((xDiff * xDiff) + (yDiff * yDiff) + (zDiff * zDiff)) <= radius;
  }
}