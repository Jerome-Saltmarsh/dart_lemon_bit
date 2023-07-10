import 'dart:math';

import 'package:gamestream_server/common/src/isometric/team_type.dart';
import 'package:gamestream_server/gamestream.dart';
import 'package:gamestream_server/lemon_math.dart';

import 'isometric_character.dart';
import 'isometric_physics.dart';
import 'isometric_position.dart';

abstract class IsometricCollider extends IsometricPosition {
  /// do not mutate directly use game.deactivateCollider
  var active = true;
  var collidable = true;
  var velocityX = 0.0;
  var velocityY = 0.0;
  var velocityZ = 0.0;
  var friction = IsometricPhysics.Friction;
  var bounce = false;
  var radius = 0.0;

  var hitable = true;
  var gravity = true;
  var physical = true;
  var fixed = true;

  var startX = 0.0;
  var startY = 0.0;
  var startZ = 0.0;

  String get name;

  var team = 0;

  IsometricCharacter? owner;


  /// CONSTRUCTOR
  IsometricCollider({
    required super.x,
    required super.y,
    required super.z,
    required double radius,
    required this.team,
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
  double get velocitySpeed => hyp2(velocityX, velocityY);
  double get velocityAngle => rad(velocityX, velocityY);
  double get left => x - radius;
  double get right => x + radius;
  double get top => y - radius;
  double get bottom => y + radius;

  /// SETTERS
  void set velocitySpeed(double value){
    assert (value >= 0);
    final currentAngle = velocityAngle;
    velocityX = adj(currentAngle, value);
    velocityY = opp(currentAngle, value);
  }

  // METHODS

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
    velocityX = adj(angle, speed);
    velocityY = opp(angle, speed);
  }

  void applyForce({
    required double force,
    required double angle,
  }) {
    if (fixed) return;
    velocityX += adj(angle, force);
    velocityY += opp(angle, force);
  }

  void clampVelocity(double value){
    if (fixed) return;
    assert (value > 0);
    if (velocitySpeed <= value) return;
    velocitySpeed = value;
  }

  void updateVelocity(){
    if (fixed) return;


    x += (velocityX * Gamestream.Fixed_Time);
    y += (velocityY * Gamestream.Fixed_Time);
    z += (velocityZ * Gamestream.Fixed_Time);
    velocityX *= friction;
    velocityY *= friction;

    if (gravity) {
      velocityZ -= IsometricPhysics.Gravity * Gamestream.Fixed_Time;
      if (velocityZ < -IsometricPhysics.Max_Fall_Velocity) {
        velocityZ = -IsometricPhysics.Max_Fall_Velocity * Gamestream.Fixed_Time;
      }
    }
  }

  /// FUNCTIONS
  static bool onSameTeam(dynamic a, dynamic b) {
    if (identical(a, b))                    return true;
    if (a is! IsometricCollider || b is! IsometricCollider)   return false;
    final aTeam = a.team;
    if (aTeam == TeamType.Alone)            return false;
    if (aTeam == TeamType.Neutral)          return true;
    final bTeam = b.team;
    if (bTeam == TeamType.Alone)            return false;
    if (bTeam == TeamType.Neutral)          return true;
    return aTeam == bTeam;
  }

  bool collidingWith(IsometricCollider that){
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

  bool isAlly(dynamic that) {
    if (identical(this, that))
      return true;
    if (that is! IsometricCollider)
      return false;
    if (!that.active)
      return false;
    if (team == TeamType.Alone)
      return false;
    final thatTeam = that.team;
    if (thatTeam == TeamType.Alone)
      return false;
    return team == thatTeam;
  }

  bool isEnemy(dynamic that) {
    if (identical(this, that))
      return false;
    if (that is! IsometricCollider)
      return false;
    if (!that.active)
      return false;
    final thatTeam = that.team;
    if (thatTeam == TeamType.Neutral)
      return false;
    if (team == TeamType.Neutral)
      return false;
    if (team == TeamType.Alone)
      return true;
    if (thatTeam == TeamType.Alone)
      return true;

    return team != thatTeam;
  }
}