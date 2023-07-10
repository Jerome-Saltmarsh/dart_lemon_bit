
import 'package:gamestream_server/common.dart';

import 'isometric_physics.dart';
import 'isometric_collider.dart';
import 'isometric_position.dart';

class IsometricProjectile extends IsometricCollider {
  var range = 0.0;
  var type = 0; // ProjectileType.dart
  var friendlyFire = false;
  var damage = 0;
  IsometricPosition? target = null;

  IsometricProjectile({
    required super.team,
    required super.x,
    required super.y,
    required super.z,
  }) : super(radius: IsometricPhysics.Projectile_Radius);

  bool get overRange => distanceTravelled > range;

  double get distanceTravelled => getDistanceXY(startX, startY);

  void reduceDistanceZFrom(IsometricPosition position){
    z += (position.z - z) * IsometricPhysics.Projectile_Z_Velocity;
  }

  @override
  String get name => ProjectileType.getName(type);
}

