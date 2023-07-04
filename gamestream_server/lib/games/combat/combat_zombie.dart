import 'dart:math';
import 'dart:typed_data';

import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/isometric.dart';

import 'package:gamestream_server/lemon_math.dart';

import 'combat_game.dart';

class CombatZombie extends IsometricCharacter {
  static const AI_Path_Size = 80;
  static const Destination_Radius = 15;
  static const Frames_Between_AI_Mode_Min = 80;
  static const Frames_Between_AI_Mode_Max = 120;

  final pathX = Uint16List(AI_Path_Size);
  final pathY = Uint16List(AI_Path_Size);
  var viewRange = 300.0;
  var chaseRange = 500.0;
  var pathIndex = 0;
  var destX = 0.0;
  var destY = 0.0;
  var spawnX = 0.0;
  var spawnY = 0.0;
  var spawnZ = 0.0;
  var spawnNodeIndex = 0;
  var wanderPause = randomInt(300, 500);
  var wanderRadius = 0.0;
  var nextTeleport = randomInt(500, 1000);
  var aiMode = AIMode.Idle;
  var aiModeNext = Frames_Between_AI_Mode_Min;
  var rounds = 0;
  Function(IsometricPlayer player)? onInteractedWith;

  CombatZombie({
    required int characterType,
    required int health,
    required int damage,
    this.wanderRadius = 200,
    double x = 0,
    double y = 0,
    double z = 0,
    this.onInteractedWith,
    String? name,
  }): super(
      characterType: characterType,
      weaponType: WeaponType.Unarmed,
      x: x,
      y: y,
      z: z,
      health: health,
      team: CombatGame.Team_Zombie,
      weaponRange: 20.0,
      weaponDamage: 1,
      weaponCooldown: 20,
  ) {
    clearDest();
    spawnX = x;
    spawnY = y;
    spawnZ = z;
  }

  int get equippedAttackDuration => 25;

  bool get arrivedAtDest =>
    (x - destX).abs() < Destination_Radius ||
    (y - destY).abs() < Destination_Radius ;

  void clearPath() {
    pathIndex = 0;
  }

  void clearDest(){
    destX = x;
    destY = y;
  }

  void faceRunDestination() {
    faceXY(destX, destY);
  }

  void faceTarget(){
    assert (target != null);
    face(target!);
  }

  void applyBehaviorWander(IsometricGame game){
    if (wanderRadius <= 0) return;
    if (target != null) return;
    if (!characterStateIdle) return;
    if (stateDuration < wanderPause) return;
    destX = spawnX + giveOrTake(wanderRadius);
    destY = spawnY + giveOrTake(wanderRadius);
    if (game.scene.getCollisionAt(destX, destY, z + Node_Height_Half)) {
       clearDest();
       return;
    }
    wanderPause = randomInt(300, 500);
  }

  bool withinChaseRange(IsometricPosition target) =>
    ((x - target.x).abs() < chaseRange) ||
    ((y - target.y).abs() < chaseRange) ;

  void shuffleAIMode(){
    aiMode = randomInt(0, 5);
    aiModeNext = randomInt(CombatZombie.Frames_Between_AI_Mode_Min, CombatZombie.Frames_Between_AI_Mode_Max);
  }

  void updateAI(){
    if (busy) return;

    aiModeNext--;
    if (aiModeNext <= 0){
      shuffleAIMode();
    }

    final target = this.target;
    if (target != null) {

      if (withinAttackRange(target) && aiMode != AIMode.Idle && aiMode != AIMode.Evade) {
        face(target);
        setCharacterStatePerforming(duration: equippedAttackDuration);
        return;
      }

      switch (aiMode) {
        case AIMode.Idle:
          setCharacterStateIdle();
          return;
        case AIMode.Pursue:
          face(target);
          if (withinAttackRange(target)) {
            setCharacterStatePerforming(duration: equippedAttackDuration);
            return;
          } else {
            destX = target.x;
            destY = target.y;
          }
          break;
        case AIMode.Evade:
          face(target);
          faceAngle += pi;
          setCharacterStateRunning();
          return;
        case AIMode.Encircle_CW:
          final targetAngle = angleBetween(x, y, target.x, target.y, ) + piEighth;
          final distance =  getDistance3(target);
          destX = target.x + adj(targetAngle, distance);
          destY = target.y + opp(targetAngle, distance);
          break;
        case AIMode.Encircle_CCW:
          final targetAngle = angleBetween(x, y, target.x, target.y, ) - piEighth;
          final distance = getDistance3(target);
          destX = target.x + adj(targetAngle, distance);
          destY = target.y + opp(targetAngle, distance);
          break;
      }
    }

    if (!arrivedAtDest) {
      faceRunDestination();
      setCharacterStateRunning();
      return;
    }

    if (pathIndex > 0){
      pathIndex--;
      destX = pathX[pathIndex].toDouble();
      destY = pathY[pathIndex].toDouble();
      faceRunDestination();
      setCharacterStateRunning;
      return;
    }
    state = CharacterState.Idle;
  }

  @override
  void customOnDead() {
    clearDest();
    clearPath();
  }
}
