

import '../isometric_engine.dart';

class Projectile extends Collider {
  var range = 0.0;
  var type = 0; // ProjectileType.dart
  var friendlyFire = false;
  var damage = 0;
  Position? target;
  Character? parent;

  Projectile({
    required super.team,
    required super.x,
    required super.y,
    required super.z,
    required super.materialType,
  }) : super(radius: Physics.Projectile_Radius);

  bool get overRange => distanceTravelled > range;

  double get distanceTravelled => getDistanceXY(
      startPositionX,
      startPositionY,
      x,
      y,
  );

  void reduceDistanceZFrom(Position position){
    z += (position.z - z) * Physics.Projectile_Z_Velocity;
  }

  @override
  String get name => ProjectileType.getName(type);

  @override
  bool onSameTeam(dynamic target) =>
      parent?.onSameTeam(target) ?? false;

}

