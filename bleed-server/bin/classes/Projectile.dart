import '../common/enums/Direction.dart';
import '../common/enums/ProjectileType.dart';
import '../interfaces/HasSquad.dart';
import '../utils.dart';
import 'Character.dart';
import 'GameObject.dart';

class Projectile extends GameObject implements HasSquad {
  late double xStart;
  late double yStart;
  Character owner;
  double range;
  int damage;
  ProjectileType type;
  Direction direction;

  int get squad => owner.squad;

  Projectile(
      double x,
      double y,
      double xVel,
      double yVel,
      this.owner,
      this.range,
      this.damage,
      this.direction,
      {
        this.type = ProjectileType.Fireball
      })
      : super(x, y, xv: xVel, yv: yVel) {
    xStart = x;
    yStart = y;
  }

  @override
  int getSquad() {
    return owner.squad;
  }
}
