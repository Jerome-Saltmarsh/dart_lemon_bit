
import 'dart:math';

import 'package:lemon_math/library.dart';

import '../common/src/tile_size.dart';

class Position3 with Position {
  var z = 0.0;

  int get indexZ => z ~/ tileSizeHalf;
  int get indexRow => x ~/ tileSize;
  int get indexColumn => y ~/ tileSize;

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

  static void sort(List<Position3> items) {
    var start = 0;
    var end = items.length;
    for (var pos = start + 1; pos < end; pos++) {
      var min = start;
      var max = pos;
      var element = items[pos];
      while (min < max) {
        var mid = min + ((max - min) >> 1);
        if (element.order <= items[mid].order) {
          max = mid;
        } else {
          min = mid + 1;
        }
      }
      items.setRange(min + 1, pos + 1, items, min);
      items[min] = element;
    }
  }

}