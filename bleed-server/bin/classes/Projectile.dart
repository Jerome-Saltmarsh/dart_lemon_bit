
import 'package:lemon_math/Vector2.dart';

import '../common/ProjectileType.dart';
import '../maths.dart';
import 'Collider.dart';
import 'GameObject.dart';

mixin Active {
  bool active = true;
}

class Projectile extends Collider with Active, Velocity {
  final start = Vector2(0, 0);
  late dynamic owner;
  late double range;
  late int damage;
  late ProjectileType type;
  Collider? target = null;
  late double speed;
  late bool collideWithEnvironment = false;
  double angle = 0;

  Projectile() : super(x: 0, y: 0, radius: 5);

  bool get overRange {
    return distanceTravelled > range;
  }

  double get distanceTravelled {
    return getDistance(start);
  }

  void setVelocityTowards(Vector2 position){
    angle = getAngle(position);
    xv = adj(angle, speed);
    yv = opp(angle, speed);
  }
}

void setProjectileAngle(Projectile projectile, double angle){
  projectile.xv = velX(angle, projectile.speed);
  projectile.yv = velY(angle, projectile.speed);
}
