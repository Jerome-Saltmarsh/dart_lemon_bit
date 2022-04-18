
import 'package:lemon_math/hypotenuse.dart';

import '../common/ProjectileType.dart';
import '../maths.dart';
import 'Collider.dart';
import 'GameObject.dart';

class Projectile extends GameObject {
  late double xStart;
  late double yStart;
  late dynamic owner;
  late double range;
  late int damage;
  late ProjectileType type;
  Collider? target = null;
  late double speed;
  late bool collideWithEnvironment = false;
  double angle = 0;

  Projectile() : super(0, 0, radius: 5);

  bool get overRange {
    return distanceTravelled > range;
  }

  double get distanceTravelled {
    return hypotenuse(x - xStart, y - yStart);
  }
}

void setProjectileAngle(Projectile projectile, double angle){
  projectile.xv = velX(angle, projectile.speed);
  projectile.yv = velY(angle, projectile.speed);
}
