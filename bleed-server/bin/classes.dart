import 'classes/Character.dart';
import 'classes/GameObject.dart';
import 'classes/Player.dart';
import 'common/classes/Vector2.dart';
import 'common/GameEventType.dart';
import 'common/Weapons.dart';
import 'enums/npc_mode.dart';
import 'settings.dart';

abstract class HasSquad {
  int getSquad();
}

extension HasSquadExtensions on HasSquad {
  bool get noSquad => getSquad() == -1;
}

bool allies(HasSquad a, HasSquad b) {
  if (a.noSquad) return false;
  if (b.noSquad) return false;
  return a.getSquad() == b.getSquad();
}

bool enemies(HasSquad a, HasSquad b) {
  return !allies(a, b);
}

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

class GameEvent extends GameObject {
  final GameEventType type;
  int frameDuration = 2;

  GameEvent(this.type, double x, double y, double xv, double yv)
      : super(x, y, xv: xv, yv: yv);
}

class Grenade extends GameObject {
  final Player owner;

  Grenade(this.owner, double xv, double yv, double zVel)
      : super(owner.x, owner.y, xv: xv, yv: yv) {
    this.zv = zVel;
  }
}
