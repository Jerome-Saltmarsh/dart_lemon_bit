import 'dart:typed_data';

import 'package:lemon_math/library.dart';

import '../common/library.dart';
import '../functions/withinRadius.dart';
import 'collider.dart';
import 'components.dart';
import 'character.dart';
import 'enemy_spawn.dart';
import 'game.dart';
import 'weapon.dart';

class AI extends Character with Material {
  static const viewRange = 200.0;
  static const chaseRange = 500.0;
  static const maxAIPathLength = 80;
  static const maxAIPathLengthMinusOne = maxAIPathLength - 3;

  final pathX = Float32List(maxAIPathLength);
  final pathY = Float32List(maxAIPathLength);
  var pathIndex = 0;
  var destX = 0.0;
  var destY = 0.0;
  var spawnX = 0.0;
  var spawnY = 0.0;
  var objective;
  var wanderRadius = 0.0;
  EnemySpawn? enemySpawn;

  bool get arrivedAtDest {
    const radius = 15;
    if ((x - destX).abs() > radius) return false;
    if ((y - destY).abs() > radius) return false;
    return true;
  }

  AI({
    required double x,
    required double y,
    required double z,
    required int health,
    required Weapon weapon,
    int team = 0,
    double speed = 3.0,
    this.wanderRadius = 0,
  }): super(
      x: x,
      y: y,
      z: z,
      health: health,
      team: team,
      equippedWeapon: weapon,
      speed: speed
  ) {
    this.material = MaterialType.Flesh;
    clearDest();
    spawnX = x;
    spawnY = y;
  }

  void clearDest(){
    destX = x;
    destY = y;
  }

  @override
  void customUpdateCharacter(Game game){
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

    applyBehaviorWander(game);

    customUpdateAI(game);
  }

  void faceDestination() {
    if (deadOrBusy) return;
    angle = getAngleBetween(x, y, destX, destY);
  }

  void customUpdateAI(Game game){

  }

  void applyBehaviorWander(Game game){
    if (wanderRadius <= 0) return;
    if (target != null) return;
    if (!characterStateIdle) return;
    if (stateDuration < wanderPause) return;
    destX = spawnX + giveOrTake(wanderRadius);
    destY = spawnY + giveOrTake(wanderRadius);
    if (game.scene.getCollisionAt(destX, destY, z + tileHeightHalf)) {
       clearDest();
       return;
    }
    wanderPause = randomInt(300, 500);
  }

  void clearTargetIf(Character value){
    if (target != value) return;
    target = objective;
  }

  bool withinViewRange(Position target) {
    if (target == objective) return true;
    return withinRadius(this, target, viewRange);
  }

  bool withinChaseRange(Position target) {
    if (target == objective) return true;
    return withinRadius(this, target, chaseRange);
  }

  @override
  void onCollisionWith(Collider other){
    if (pathIndex < 0) return;
    if (other is AI) {
      rotateAround(other, 0.2);
    }
  }
}
