
import 'dart:math';

import '../node_size.dart';

class Vector3 {
  var x = 0.0;
  var y = 0.0;
  var z = 0.0;

  int get indexRow => x ~/ Node_Size;
  int get indexColumn => y ~/ Node_Size;
  int get indexZ => z ~/ Node_Height;

  double get renderX => (x - y) * 0.5;
  double get renderY => ((y + x) * 0.5) - z;
  double get order => (y + x);

  bool withinDistance(double x, double y, double z, num radius){
    final xDiff = (this.x - x).abs();
    if (xDiff > radius) return false;

    final yDiff = (this.y - y).abs();
    if (yDiff > radius) return false;

    final zDiff = (this.z - z).abs();
    if (zDiff > radius) return false;

    return sqrt((xDiff * xDiff) + (yDiff * yDiff) + (zDiff * zDiff)) <= radius;
  }

  /// FUNCTIONS
  static void sort(List<Vector3> items) {
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