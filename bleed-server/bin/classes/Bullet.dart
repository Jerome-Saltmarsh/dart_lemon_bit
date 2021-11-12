import '../classes.dart';
import '../common/Weapons.dart';
import 'Character.dart';
import 'GameObject.dart';

class Bullet extends GameObject implements HasSquad {
  late double xStart;
  late double yStart;
  Character owner;
  double range;
  int damage;
  late Weapon weapon;

  int get squad => owner.squad;

  Bullet(double x, double y, double xVel, double yVel, this.owner, this.range,
      this.damage)
      : super(x, y, xv: xVel, yv: yVel) {
    xStart = x;
    yStart = y;
    weapon = owner.weapon;
  }

  @override
  int getSquad() {
    return owner.squad;
  }
}
