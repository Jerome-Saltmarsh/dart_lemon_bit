import 'dart:math';

import 'package:lemon_math/library.dart';

import 'position3.dart';
import 'components.dart';

class Collider extends Position3 with Radius {
  double zVelocity = 0;
  double get left => x - radius;
  double get right => x + radius;
  double get top => y - radius;
  double get bottom => y + radius;
  var collidable = true;

  Collider({
    required double x,
    required double y,
    required double z,
    required double radius
  }) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.radius = radius;
  }

  void onCollisionWith(Collider other){ }

  bool withinBounds(Vector2 position) {
    return getDistance(position) <= radius;
  }

  double getOverlap(Collider collider){
    return (radius + collider.radius) - getDistance(collider);
  }

  void onStruck(dynamic src){

  }

  double distanceFromPos3(Position3 value) {
    return distanceFromXYZ(value.x, value.y, value.z);
  }

  double distanceFromXYZ(double x, double y, double z) {
    final a = this.x - x;
    final b = this.y - y;
    final c = this.z - z;
    return sqrt((a * a) + (b * b) + (c * c));
  }
}