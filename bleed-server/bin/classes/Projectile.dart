import 'package:lemon_math/Vector2.dart';

import '../common/enums/Direction.dart';
import '../common/enums/ProjectileType.dart';
import '../interfaces/HasSquad.dart';
import '../maths.dart';
import 'Character.dart';
import 'GameObject.dart';

class Projectile extends GameObject implements HasSquad {
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

  @override
  int getSquad() {
    return owner.team;
  }
}

void setProjectileAngle(Projectile projectile, double angle){
  projectile.xv = velX(angle, projectile.speed);
  projectile.yv = velY(angle, projectile.speed);
}
