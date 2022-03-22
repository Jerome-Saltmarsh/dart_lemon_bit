
import 'package:lemon_math/hypotenuse.dart';

import '../common/enums/ProjectileType.dart';
import '../maths.dart';
import 'Character.dart';
import 'GameObject.dart';

class Projectile extends GameObject {
  late double xStart;
  late double yStart;
  late Character owner;
  late double range;
  late int damage;
  late ProjectileType type;
  late Character? target;
  late double speed;
  late bool collideWithEnvironment = false;
  double angle = 0;

  Projectile():super(0, 0);

  int get squad => owner.team;

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
