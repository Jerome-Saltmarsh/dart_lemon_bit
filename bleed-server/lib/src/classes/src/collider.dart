import 'dart:math';

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/game_physics.dart';
import 'package:lemon_math/library.dart';


class Collider extends Position3 {
  var active = true;
  var mass = 1.0;
  var velocityX = 0.0;
  var velocityY = 0.0;
  var velocityZ = 0.0;
  var team = 0;
  var radius = 0.0;
  /// If false this object is completely ignored by collision detection
  var collidable = true;
  /// an item which is not physical may still cause a collision detection
  var physical = true;
  /// If false this object will not be moved during a collision
  var moveOnCollision = true;
  var applyGravity = false;

  var startX = 0.0;
  var startY = 0.0;
  var startZ = 0.0;

  Character? owner;
  var damage = 0;

  /// CONSTRUCTOR
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

  /// GETTERS
  /// Expensive Operation
  bool get inactive => !active;
  double get velocitySpeed => getHypotenuse(velocityX, velocityY);
  double get velocityAngle => getAngle(velocityX, velocityY);
  double get left => x - radius;
  double get right => x + radius;
  double get top => y - radius;
  double get bottom => y + radius;

  /// SETTERS
  void set velocitySpeed(double value){
    assert (value >= 0);
    final currentAngle = velocityAngle;
    velocityX = getAdjacent(currentAngle, value);
    velocityY = getOpposite(currentAngle, value);
  }

  // METHODS

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

  void setVelocity(double angle, double speed){
    velocityX = getAdjacent(angle, speed);
    velocityY = getOpposite(angle, speed);
  }

  void applyFriction(double amount){
    velocityX *= amount;
    velocityY *= amount;
  }

  void applyForce({
    required double force,
    required double angle,
  }) {
    velocityX += getAdjacent(angle, force);
    velocityY += getOpposite(angle, force);
  }

  void updatePhysics(){
    if (applyGravity) {
      velocityZ -= GamePhysics.Gravity;
      velocityZ *= GamePhysics.Friction;
    }
    velocityX *= GamePhysics.Friction;
    velocityY *= GamePhysics.Friction;
    x += velocityX;
    y += velocityY;
    z += velocityZ;
  }

  /// FUNCTIONS

  static bool onSameTeam(dynamic a, dynamic b){
    if (a == b) return true;
    if (a is! Collider) return false;
    if (b is! Collider) return false;
    if (a.team == TeamType.Alone) return false;
    if (b.team == TeamType.Alone) return false;
    if (a.team == TeamType.Neutral) return true;
    if (b.team == TeamType.Neutral) return true;
    return a.team == b.team;
  }
}