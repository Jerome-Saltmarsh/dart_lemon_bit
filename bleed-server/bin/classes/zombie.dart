

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
  void customUpdateCharacter(Game game) {
    if (deadOrBusy) return;
    // updateAI(game);

    final target = this.target;
    if (target != null) {
        if (withinAttackRange(target)) {
          attackTarget(target);
          return;
        }
        const runAtTargetDistance = 100;
        if ((getDistance(target) < runAtTargetDistance)) {
          return runAt(target);
        }
    }

    if (pathIndex >= 0) {
      if (arrivedAtDest) return nextPath();
      // @on npc going to path
      face(dest);
      state = CharacterState.Running;
      return;
    }

    if (idleDuration++ > 120) {
      idleDuration = 0;
      if (objective == null) {
        game.npcSetRandomDestination(this);
      }
    }

    state = CharacterState.Idle;
  }
}