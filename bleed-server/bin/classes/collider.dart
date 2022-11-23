import 'dart:math';

import 'package:lemon_math/library.dart';

import 'position3.dart';

class Collider extends Position3 {
  var team = 0;
  var radius = 0.0;
  double zVelocity = 0;
  double get left => x - radius;
  double get right => x + radius;
  double get top => y - radius;
  double get bottom => y + radius;
  /// If false this object is completely ignored by collision detection
  var collidable = true;
  /// an item which is not physical may still cause a collision detection
  var physical = true;
  /// If false this object will not be moved during a collision
  var moveOnCollision = true;

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

  double distanceFromPos3(Position3 value) {
    return distanceFromXYZ(value.x, value.y, value.z);
  }

  double distanceFromPos2(Position value) {
    return distanceFromXY(value.x, value.y);
  }

  double distanceFromXYZ(double x, double y, double z) {
    final a = this.x - x;
    final b = this.y - y;
    final c = this.z - z;
    return sqrt((a * a) + (b * b) + (c * c));
  }

  double distanceFromXY(double x, double y) {
    final a = this.x - x;
    final b = this.y - y;
    return sqrt((a * a) + (b * b));
  }

  static bool onSameTeam(dynamic a, dynamic b){
    if (a == b) return true;
    if (a is Collider == false) return false;
    if (b is Collider == false) return false;
    if (a.team == 0) return false;
    return a.team == b.team;
  }
}