
import 'dart:math';

import 'Collider.dart';

class GameObject extends Collider {
  var z = 0.0;
  var xv = 0.0;
  var yv = 0.0;
  var zv = 0.0;
  var active = true;

  double get angle => atan2(xv, yv);
  bool get inactive => !active;

  GameObject(double x, double y, {
    this.z = 0,
    this.xv = 0,
    this.yv = 0,
    this.zv = 0,
    required double radius,
  }) : super(x, y, radius);
}