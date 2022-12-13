
import 'package:lemon_math/library.dart';

import 'collider.dart';
import 'position3.dart';

class Projectile extends Collider {
  final start = Vector2(0, 0);
  var range = 0.0;
  var type = 0; // ProjectileType.dart
  var damage = 0;
  Position3? target = null;
  bool active = true;

  Projectile() : super(x: 0, y: 0, z: 0, radius: 10);

  bool get inactive => !active;

  bool get overRange {
    return distanceTravelled > range;
  }

  double get distanceTravelled {
    return getDistance(start);
  }

  void deactivate(){
    active = false;
  }

  void setVelocityTowards(Position3 position){
    z += (position.z - z) * 0.05;
  }
}

