
import 'package:bleed_server/src/games/isometric/isometric_physics.dart';

import 'isometric_collider.dart';
import 'isometric_position.dart';

class IsometricProjectile extends IsometricCollider {
  var range = 0.0;
  var type = 0; // ProjectileType.dart
  IsometricPosition? target = null;

  IsometricProjectile() : super(x: 0, y: 0, z: 0, radius: IsometricPhysics.Projectile_Radius);

  bool get overRange => distanceTravelled > range;

  double get distanceTravelled => getDistanceXY(startX, startY);

  void reduceDistanceZFrom(IsometricPosition position){
    z += (position.z - z) * IsometricPhysics.Projectile_Z_Velocity;
  }
}

