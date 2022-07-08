

import '../common/library.dart';
import 'ai.dart';
import 'game.dart';
import 'weapon.dart';

class Zombie extends AI {
  Zombie({
    required double x,
    required double y,
    required double z,
    required int health,
    required int damage,
  }) : super(
      x: x,
      y: y,
      z: z,
      health: health,
      weapon: Weapon(type: WeaponType.Unarmed, damage: damage),
  );

  @override
  void customUpdateAI(Game game) {
    // applyBehaviorWander();
  }
}