import 'dart:math';

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/game_physics.dart';
import 'package:lemon_math/library.dart';

class Collider extends Position3 {
  var active = true;
  var velocityX = 0.0;
  var velocityY = 0.0;
  var velocityZ = 0.0;
  var friction = GamePhysics.Friction;
  var bounce = false;
  var team = 0;
  var radius = 0.0;

  var hitable = true;
  var gravity = true;
  var physical = true;
  var fixed = true;

  var startX = 0.0;
  var startY = 0.0;
  var startZ = 0.0;

  var sizeX = 0.0;
  var sizeY = 0.0;

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
    saveStartAsCurrentPosition();
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

  void applyForce({
    required double force,
    required double angle,
  }) {
    if (fixed) return;
    velocityX += getAdjacent(angle, force);
    velocityY += getOpposite(angle, force);
  }

  void clampVelocity(double value){
    if (fixed) return;
    assert (value > 0);
    if (velocitySpeed <= value) return;
    velocitySpeed = value;
  }

  void applyVelocity(){
    if (fixed) return;
    x += velocityX;
    y += velocityY;
    z += velocityZ;
  }

  void applyFriction() {
    if (fixed) return;
    velocityX *= friction;
    velocityY *= friction;
    // velocityZ *= friction;
  }

  void applyGravity(){
    if (!gravity) return;
    velocityZ -= GamePhysics.Gravity;

    if (velocityZ < -GamePhysics.Max_Fall_Velocity) {
      velocityZ = -GamePhysics.Max_Fall_Velocity;
    }
  }

  /// FUNCTIONS
  static bool onSameTeam(dynamic a, dynamic b) {
    if (identical(a, b))                    return true;
    if (a is! Collider || b is! Collider)   return false;
    final aTeam = a.team;
    if (aTeam == TeamType.Alone)            return false;
    if (aTeam == TeamType.Neutral)          return true;
    final bTeam = b.team;
    if (bTeam == TeamType.Alone)            return false;
    if (bTeam == TeamType.Neutral)          return true;
    return aTeam == bTeam;
  }

  bool collidingWith(Collider that){
    if (!active) return false;
    // if (!strikable) return false;
    if (!that.active) return false;
    // if (!that.strikable) return false;
    if (left > that.right) return false;
    if (right < that.left) return false;
    if (top > that.bottom) return false;
    if (bottom < that.top) return false;
     return true;
  }

  void saveStartAsCurrentPosition(){
    startX = x;
    startY = y;
    startZ = z;
  }
}