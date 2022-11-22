
import 'package:lemon_math/library.dart';

import 'character.dart';
import 'collider.dart';
import 'position3.dart';
import 'components.dart';


class Projectile extends Collider with Active, Velocity, FaceDirection {
  final start = Vector2(0, 0);
  var range = 0.0;
  var type = 0; // ProjectileType.dart
  var damage = 0;
  var collideWithEnvironment = false;
  Position3? target = null;
  Character? owner;

  Projectile() : super(x: 0, y: 0, z: 0, radius: 5);

  bool get overRange {
    return distanceTravelled > range;
  }

  double get distanceTravelled {
    return getDistance(start);
  }

  void setVelocityTowards(Position3 position){
    faceAngle = this.getAngle(position);
    z += (position.z - z) * 0.05;
  }
}

