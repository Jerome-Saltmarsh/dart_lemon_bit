
import 'package:bleed_server/src/games/isometric/isometric_physics.dart';

import '../../classes/src/collider.dart';
import '../../classes/src/position3.dart';

class IsometricProjectile extends Collider {
  var range = 0.0;
  var type = 0; // ProjectileType.dart
  Position3? target = null;

  IsometricProjectile() : super(x: 0, y: 0, z: 0, radius: IsometricPhysics.Projectile_Radius);

  bool get overRange => distanceTravelled > range;

  double get distanceTravelled => getDistanceXY(startX, startY);

  void reduceDistanceZFrom(Position3 position){
    z += (position.z - z) * IsometricPhysics.Projectile_Z_Velocity;
  }
}

