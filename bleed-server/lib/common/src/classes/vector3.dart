
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
}