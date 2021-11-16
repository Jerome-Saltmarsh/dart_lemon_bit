import '../common/Weapons.dart';
import '../common/classes/Vector2.dart';
import '../enums/npc_mode.dart';
import '../settings.dart';
import 'Character.dart';

final Character _nonTarget =
Character(x: 0, y: 0, weapon: Weapon.AssaultRifle, health: 0, speed: 0);

class Npc extends Character {
  Character target = _nonTarget;
  List<Vector2> path = [];
  int pointMultiplier = 1;
  NpcMode mode = NpcMode.Aggressive;

  Npc({
    required double x,
    required double y,
    int health = 100,
    Weapon weapon = Weapon.Unarmed,
  })
      : super(
      x: x,
      y: y,
      weapon: weapon,
      health: health,
      speed: settings.zombieSpeed);

  bool get targetSet => target != _nonTarget;

  void clearTarget() {
    target = _nonTarget;
    path = [];
  }
}
