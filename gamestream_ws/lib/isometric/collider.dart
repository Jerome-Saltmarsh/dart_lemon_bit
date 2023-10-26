import 'dart:math';

import 'package:gamestream_ws/gamestream/amulet.dart';
import 'package:gamestream_ws/packages.dart';

import 'character.dart';
import 'physics.dart';
import 'position.dart';

abstract class Collider extends Position {
  /// do not mutate directly use game.deactivateCollider
  var active = true;

  var physicsVelocityX = 0.0;
  var physicsVelocityY = 0.0;
  var physicsVelocityZ = 0.0;
  var physicsFriction = Physics.Friction;
  var physicsBounce = false;
  var physicsRadius = 0.0;

  var enabledCollidable = true;
  var enabledHit = true;
  var enabledGravity = true;
  var enabledPhysical = true;
  var enabledFixed = true;

  var startPositionX = 0.0;
  var startPositionY = 0.0;
  var startPositionZ = 0.0;

  int materialType;

  String get name;

  var team = 0;


  /// CONSTRUCTOR
  Collider({
    required super.x,
    required super.y,
    required super.z,
    required double radius,
    required this.team,
    required this.materialType,
  }) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.physicsRadius = radius;
    saveStartAsCurrentPosition();
  }

  /// GETTERS
  /// Expensive Operation
  bool get inactive => !active;

  /// Expensive Operation
  double get velocitySpeed => hyp2(physicsVelocityX, physicsVelocityY);

  /// Expensive Operation
  double get velocityAngle => rad(physicsVelocityX, physicsVelocityY);

  /// Expensive Operation
  double get boundsLeft => x - physicsRadius;

  /// Expensive Operation
  double get boundsRight => x + physicsRadius;

  /// Expensive Operation
  double get boundsTop => y - physicsRadius;

  /// Expensive Operation
  double get boundsBottom => y + physicsRadius;

  /// SETTERS
  void set velocitySpeed(double value){
    assert (value >= 0);
    final currentAngle = velocityAngle;
    physicsVelocityX = adj(currentAngle, value);
    physicsVelocityY = opp(currentAngle, value);
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
    physicsVelocityX = adj(angle, speed);
    physicsVelocityY = opp(angle, speed);
  }

  void applyForce({
    required double force,
    required double angle,
  }) {
    if (enabledFixed) return;
    physicsVelocityX += adj(angle, force);
    physicsVelocityY += opp(angle, force);
  }

  void clampVelocity(double value){
    if (enabledFixed) return;
    assert (value > 0);
    if (velocitySpeed <= value) return;
    velocitySpeed = value;
  }

  void updateVelocity(){
    if (enabledFixed) return;


    x += (physicsVelocityX * Amulet.Fixed_Time);
    y += (physicsVelocityY * Amulet.Fixed_Time);
    z += (physicsVelocityZ * Amulet.Fixed_Time);
    physicsVelocityX *= physicsFriction;
    physicsVelocityY *= physicsFriction;

    if (enabledGravity) {
      physicsVelocityZ -= Physics.Gravity * Amulet.Fixed_Time;
      if (physicsVelocityZ < -Physics.Max_Fall_Velocity) {
        physicsVelocityZ = -Physics.Max_Fall_Velocity * Amulet.Fixed_Time;
      }
    }
  }

  /// FUNCTIONS
  bool onSameTeam(dynamic a);

  // static bool onSameTeam(dynamic a, dynamic b) {
  //   if (identical(a, b))                    return true;
  //   if (a is! Collider || b is! Collider)   return false;
  //   final aTeam = a.team;
  //   if (aTeam == TeamType.Alone)            return false;
  //   if (aTeam == TeamType.Neutral)          return true;
  //   final bTeam = b.team;
  //   if (bTeam == TeamType.Alone)            return false;
  //   if (bTeam == TeamType.Neutral)          return true;
  //   return aTeam == bTeam;
  // }

  bool collidingWith(Collider that){
    if (!active) return false;
    // if (!strikable) return false;
    if (!that.active) return false;
    // if (!that.strikable) return false;
    if (boundsLeft > that.boundsRight) return false;
    if (boundsRight < that.boundsLeft) return false;
    if (boundsTop > that.boundsBottom) return false;
    if (boundsBottom < that.boundsTop) return false;
     return true;
  }

  void saveStartAsCurrentPosition(){
    startPositionX = x;
    startPositionY = y;
    startPositionZ = z;
  }

  bool isAlly(dynamic that) {
    if (identical(this, that))
      return true;
    if (that is! Collider)
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
    if (that is! Collider)
      return false;
    if (that is Character && !that.aliveAndActive)
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

  void deactivate(){
    active = false;
    physicsVelocityX = 0;
    physicsVelocityY = 0;
    physicsVelocityZ = 0;
  }
}