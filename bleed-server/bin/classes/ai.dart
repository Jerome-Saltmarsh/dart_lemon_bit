import 'dart:typed_data';

import 'package:lemon_math/library.dart';

import '../common/library.dart';
import '../constants/frames_per_second.dart';
import '../functions/withinRadius.dart';
import 'collider.dart';
import 'character.dart';
import 'game.dart';
import 'player.dart';
import 'position3.dart';
import 'weapon.dart';

abstract class AI extends Character {
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
  var spawnZ = 0.0;
  var objective;
  var respawn = 0;
  var wanderPause = randomInt(300, 500);
  var wanderRadius = 0.0;

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
    required Game game,
    int team = 0,
    double speed = 3.0,
    this.wanderRadius = 0,
  }): super(
      x: x,
      y: y,
      z: z,
      // game: game,
      health: health,
      team: team,
      weapon: weapon,
      speed: speed
  ) {
    clearDest();
    spawnX = x;
    spawnY = y;
    spawnZ = z;
  }

  @override
  void onPlayerRemoved(Player player) {
    clearTargetIf(player);
  }

  @override
  void onDeath(){
    clearTarget();
    clearPath();
    clearDest();
    const framesPerMinute = framesPerSecond * secondsPerMinute;
    const respawnDuration = framesPerMinute * 1;
    respawn = respawnDuration;
  }

  @override
  void onStruckBy(src) {
    if (target == null) {
      target = src;
    }
  }

  void clearPath() {
    pathIndex = -1;
  }

  void clearDest(){
    destX = x;
    destY = y;
  }


  void customUpdateCharacter(Game game){
    if (deadOrBusy) return;

    final target = this.target;
    if (target != null) {
      if (withinAttackRange(target)) {
        return attackTarget(target);
      }
      if ((getDistance(target) < 300)) {
        destX = target.x;
        destY = target.y;
      }
    }

    if (!arrivedAtDest) {
      final destAngle = getDestinationAngle();
      final r = radius + 2;

      if (!getCollisionInDirection(game: game, angle: destAngle, distance: r)){
        faceAngle = getDestinationAngle();
      } else
      if (!getCollisionInDirection(game: game, angle: destAngle - piHalf, distance: r)){
        faceAngle = destAngle - piHalf;
      } else
      if (!getCollisionInDirection(game: game, angle: destAngle + piHalf, distance: r)){
        faceAngle = destAngle + piHalf;
      }
      return  game.setCharacterStateRunning(this);
    }

    if (pathIndex > 0){
      pathIndex--;
      destX = pathX[pathIndex];
      destY = pathY[pathIndex];
      faceAngle = getDestinationAngle();
      game.setCharacterStateRunning(this);
      return;
    }
    state = CharacterState.Idle;
    applyBehaviorWander(game);
    customUpdateAI(game);
  }

  double getDestinationAngle(){
    return getAngleBetween(destX, destY, x, y);
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

  bool withinViewRange(Position3 target) {
    if (target == objective) return true;
    return withinRadius(this, target, viewRange);
  }

  bool withinChaseRange(Position3 target) {
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
