
import 'package:lemon_math/library.dart';

import '../maths.dart';
import 'Collider.dart';
import 'components.dart';


class Projectile extends Collider with Active, Velocity {
  final start = Vector2(0, 0);
  late dynamic owner;
  late double range;
  late int damage;
  late int type; // TechType.dart
  late int level;
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

  void setVelocityTowards(Position position){
    angle = this.getAngle(position);
    xv = adj(angle, speed);
    yv = opp(angle, speed);
  }
}

void setProjectileAngle(Projectile projectile, double angle){
  projectile.xv = velX(angle, projectile.speed);
  projectile.yv = velY(angle, projectile.speed);
}
