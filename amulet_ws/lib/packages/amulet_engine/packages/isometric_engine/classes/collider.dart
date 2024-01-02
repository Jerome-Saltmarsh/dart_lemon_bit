import 'dart:math';

import '../isometric_engine.dart';

abstract class Collider extends Position {
  /// do not mutate directly use game.deactivateCollider
  var active = true;

  var velocityX = 0.0;
  var velocityY = 0.0;
  var velocityZ = 0.0;
  var physicsFriction = Physics.Friction;
  var physicsBounce = false;
  var radius = 0.0;

  var collidable = true;
  var hitable = true;
  var gravity = true;
  var physical = true;
  var fixed = true;

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
    required this.radius,
    required this.team,
    required this.materialType,
  }) {
    saveStartAsCurrentPosition();
  }

  /// GETTERS
  /// Expensive Operation
  bool get inactive => !active;

  /// Expensive Operation
  double get velocitySpeed => hyp2(velocityX, velocityY);

  /// Expensive Operation
  double get velocityAngle => rad(velocityX, velocityY);

  /// Expensive Operation
  double get boundsLeft => x - radius;

  /// Expensive Operation
  double get boundsRight => x + radius;

  /// Expensive Operation
  double get boundsTop => y - radius;

  /// Expensive Operation
  double get boundsBottom => y + radius;

  /// SETTERS
  set velocitySpeed(double value){
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


    x += (velocityX * Fixed_Time);
    y += (velocityY * Fixed_Time);
    z += (velocityZ * Fixed_Time);
    velocityX *= physicsFriction;
    velocityY *= physicsFriction;

    if (gravity) {
      velocityZ -= Physics.Gravity * Fixed_Time;
      if (velocityZ < -Physics.Max_Fall_Velocity) {
        velocityZ = -Physics.Max_Fall_Velocity * Fixed_Time;
      }
    }
  }

  /// FUNCTIONS
  bool onSameTeam(dynamic a);


  bool collidingWith(Collider that){
    if (!active) return false;
    if (!that.active) return false;
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
    if (identical(this, that)) {
      return true;
    }
    if (that is! Collider) {
      return false;
    }
    if (!that.active) {
      return false;
    }
    if (team == TeamType.Alone) {
      return false;
    }
    final thatTeam = that.team;
    if (thatTeam == TeamType.Alone) {
      return false;
    }
    return team == thatTeam;
  }

  bool isEnemy(dynamic that) {
    if (identical(this, that)) {
      return false;
    }
    if (that is! Collider) {
      return false;
    }
    if (that is Character && !that.aliveAndActive) {
      return false;
    }
    final thatTeam = that.team;
    if (thatTeam == TeamType.Neutral) {
      return false;
    }
    if (team == TeamType.Neutral) {
      return false;
    }
    if (team == TeamType.Alone) {
      return true;
    }
    if (thatTeam == TeamType.Alone) {
      return true;
    }

    return team != thatTeam;
  }

  void deactivate(){
    active = false;
    velocityX = 0;
    velocityY = 0;
    velocityZ = 0;
  }

  void moveToStartPosition(){
    x = startPositionX;
    y = startPositionY;
    z = startPositionZ;
  }
}