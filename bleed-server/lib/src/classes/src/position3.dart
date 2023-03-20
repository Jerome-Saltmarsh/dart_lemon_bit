
import 'package:lemon_math/library.dart';

import 'package:bleed_server/gamestream.dart';

class Position3 with Position {
  var z = 0.0;

  int get indexRow => x ~/ Node_Size;
  int get indexColumn => y ~/ Node_Size;
  int get indexZ => z ~/ Node_Size_Half;
  double get renderX => (x - y) * 0.5;
  double get renderY => ((y + x) * 0.5) - z;
  double get order => (y + x + z);

  Position3 set({double? x, double? y, double? z}){
     if (x != null) this.x = x;
     if (y != null) this.y = y;
     if (z != null) this.x = z;
     return this;
  }

  bool withinRadius(Position3 position3, double radius){
    return withinDistance(position3.x, position3.y, position3.z, radius);
  }

  bool withinRadiusCheap(Position3 position3, double radius) =>
     ((this.x - position3.x).abs() < radius) &&
     ((this.y - position3.y).abs() < radius) ;

  bool withinDistance(double x, double y, double z, double radius){
    final xDiff = (this.x - x).abs();
    if (xDiff > radius) return false;

    final yDiff = (this.y - y).abs();
    if (yDiff > radius) return false;

    final zDiff = (this.z - z).abs();
    if (zDiff > radius) return false;

    return ((xDiff * xDiff) + (yDiff * yDiff) + (zDiff * zDiff)) <= radius * radius;
  }

  static bool compare(Position3 a, Position3 b){
    final aRowColumn = a.indexRow + a.indexColumn;
    final bRowColumn = b.indexRow + b.indexColumn;

    if (aRowColumn > bRowColumn) return false;
    if (aRowColumn < bRowColumn) return true;

    final aIndexZ = a.z;
    final bIndexZ = b.z;

    if (aIndexZ > bIndexZ) return false;
    if (aIndexZ < bIndexZ) return true;

    return a.order < b.order;
  }


  /// FUNCTIONS
  ///
  static void sort(List<Position3> items) {
    var start = 0;
    var end = items.length;
    for (var pos = start + 1; pos < end; pos++) {
      var min = start;
      var max = pos;
      var element = items[pos];
      while (min < max) {
        var mid = min + ((max - min) >> 1);
        if (compare(element, items[mid])) {
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