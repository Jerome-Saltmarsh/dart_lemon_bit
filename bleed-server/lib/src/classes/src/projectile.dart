
import 'collider.dart';
import 'position3.dart';

class Projectile extends Collider {
  var range = 0.0;
  var type = 0; // ProjectileType.dart
  var damage = 0;
  Position3? target = null;

  Projectile() : super(x: 0, y: 0, z: 0, radius: 10);

  bool get overRange {
    return distanceTravelled > range;
  }

  double get distanceTravelled {
    return getDistanceXY(startX, startY);
  }

  void setVelocityTowards(Position3 position){
    z += (position.z - z) * 0.05;
  }
}

