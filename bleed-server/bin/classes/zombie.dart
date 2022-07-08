

import 'package:lemon_math/library.dart';

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
    if (deadOrBusy) return;

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

    applyBehaviorWander();

    if (!arrivedAtDest){
      faceDestination();
      setCharacterStateRunning();
      return;
    }
    if (pathIndex > 0){
       pathIndex--;
       destX = pathX[pathIndex];
       destY = pathY[pathIndex];
       faceDestination();
       setCharacterStateRunning();
       return;
    }
    state = CharacterState.Idle;
  }

  void faceDestination() {
    if (deadOrBusy) return;
    angle = getAngleBetween(x, y, destX, destY);
  }
}