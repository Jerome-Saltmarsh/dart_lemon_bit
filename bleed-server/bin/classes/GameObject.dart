
import 'dart:math';

import 'package:lemon_math/Vector2.dart';

class GameObject extends Vector2 {
  var z = 0.0;
  var xv = 0.0;
  var yv = 0.0;
  var zv = 0.0;
  var radius = 0.0;
  var collidable = true;
  var active = true;

  double get angle => atan2(xv, yv);
  double get left => x - radius;
  double get right => x + radius;
  double get top => y - radius;
  double get bottom => y + radius;
  bool get inactive => !active;

  GameObject(double x, double y, {
    this.z = 0,
    this.xv = 0,
    this.yv = 0,
    this.zv = 0,
    this.radius = 5
  }) : super(x, y);
}