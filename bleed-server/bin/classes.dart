import 'classes/Character.dart';
import 'classes/GameObject.dart';
import 'classes/Player.dart';
import 'common/GameEventType.dart';
import 'common/Weapons.dart';

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

class Grenade extends GameObject {
  final Player owner;

  Grenade(this.owner, double xv, double yv, double zVel)
      : super(owner.x, owner.y, xv: xv, yv: yv) {
    this.zv = zVel;
  }
}
