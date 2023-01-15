
import 'package:bleed_server/src/game_physics.dart';

import 'collider.dart';
import 'position3.dart';

class Projectile extends Collider {
  var range = 0.0;
  var type = 0; // ProjectileType.dart
  Position3? target = null;

  Projectile() : super(x: 0, y: 0, z: 0, radius: GamePhysics.Projectile_Radius);

  bool get overRange => distanceTravelled > range;

  double get distanceTravelled => getDistanceXY(startX, startY);

  void reduceDistanceZFrom(Position3 position){
    z += (position.z - z) * GamePhysics.Projectile_Z_Velocity;
  }
}

