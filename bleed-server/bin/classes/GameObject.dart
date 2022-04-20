
import 'dart:math';

mixin Velocity {
  var z = 0.0;
  var xv = 0.0;
  var yv = 0.0;
  var zv = 0.0;
  double get angle => atan2(xv, yv);
}