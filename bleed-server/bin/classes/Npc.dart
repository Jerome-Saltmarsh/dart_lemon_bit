import '../common/CharacterType.dart';
import '../common/WeaponType.dart';
import '../common/classes/Vector2.dart';
import '../enums/npc_mode.dart';
import '../settings.dart';
import 'Character.dart';
import 'Weapon.dart';

final Character _nonTarget =
  Character(
      type: CharacterType.Human,
      x: 0,
      y: 0,
      weapons: [Weapon(type: WeaponType.Unarmed, damage: 0, capacity: 0)],
      health: 0,
      speed: 0
  );

class Npc extends Character {
  Character target = _nonTarget;
  List<Vector2> path = [];
  NpcMode mode = NpcMode.Aggressive;

  int experience;

  Npc({
    required CharacterType type,
    required double x,
    required double y,
    required int health,
    Weapon? weapon,
    this.experience = 0,
  })
      : super(
      type: type,
      x: x,
      y: y,
      weapons: weapon != null ? [weapon] : [],
      health: health,
      speed: settings.zombieSpeed,

  );

  bool get targetSet => target != _nonTarget;

  void clearTarget() {
    target = _nonTarget;
    path = [];
  }
}
