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
  var objective;
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
  }

  void clearDest(){
    destX = x;
    destY = y;
  }

  @override
  void customUpdateCharacter(Game game){
    customUpdateAI(game);
  }

  void customUpdateAI(Game game){

  }

  void applyBehaviorWander(){
    if (target != null) return;
    if (!characterStateIdle) return;
    if (stateDuration < 300) return;
    if (enemySpawn == null) return;
    const radius = 150;
    destX = enemySpawn!.x + giveOrTake(radius);
    destY = enemySpawn!.y + giveOrTake(radius);
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
