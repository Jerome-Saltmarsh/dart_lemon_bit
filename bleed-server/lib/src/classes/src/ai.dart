import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_server/src/maths/get_distance_between_v3.dart';
import 'package:lemon_math/library.dart';

import 'package:bleed_server/gamestream.dart';

class AI extends Character {
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
  var respawn = 0;
  var wanderPause = randomInt(300, 500);
  var wanderRadius = 0.0;
  var nextTeleport = randomInt(500, 1000);
  var aiMode = AIMode.Idle;
  var aiModeNext = Frames_Between_AI_Mode_Min;
  Function(Player player)? onInteractedWith;

  AI({
    required int characterType,
    required int health,
    required int weaponType,
    required int damage,
    required int team,
    this.wanderRadius = 200,
    double x = 0,
    double y = 0,
    double z = 0,
    this.onInteractedWith,
    String? name,
  }): super(
      characterType: characterType,
      x: x,
      y: y,
      z: z,
      health: health,
      team: team,
      weaponType: weaponType,
      headType: ItemType.Head_Wizards_Hat,
      bodyType: ItemType.Body_Tunic_Padded,
      damage: damage,
  ) {
    clearDest();
    spawnX = x;
    spawnY = y;
    spawnZ = z;
  }

  bool get arrivedAtDest =>
    (x - destX).abs() < Destination_Radius ||
    (y - destY).abs() < Destination_Radius ;

  void clearPath() {
    pathIndex = -1;
  }

  void clearDest(){
    destX = x;
    destY = y;
  }

  void faceDestination() {
    faceXY(destX, destY);
  }

  void faceTarget(){
    assert (target != null);
    face(target!);
  }

  void applyBehaviorWander(Game game){
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

  bool withinViewRange(Position3 target) {
    return withinRadius(target, viewRange);
  }

  bool withinChaseRange(Position3 target) {
    return withinRadius(target, chaseRange);
  }

  void shuffleAIMode(){
    aiMode = randomInt(0, 5);
    aiModeNext = randomInt(AI.Frames_Between_AI_Mode_Min, AI.Frames_Between_AI_Mode_Max);
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
          final targetAngle = getAngleBetween(target.x, target.y, x, y) + piEighth;
          final distance = getDistanceBetweenV3(this, target);
          destX = target.x + getAdjacent(targetAngle, distance);
          destY = target.y + getOpposite(targetAngle, distance);
          break;
        case AIMode.Encircle_CCW:
          final targetAngle = getAngleBetween(target.x, target.y, x, y) - piEighth;
          final distance = getDistanceBetweenV3(this, target);
          destX = target.x + getAdjacent(targetAngle, distance);
          destY = target.y + getOpposite(targetAngle, distance);
          break;
      }
    }

    if (!arrivedAtDest) {
      faceDestination();
      setCharacterStateRunning();
      return;
    }

    if (pathIndex > 0){
      pathIndex--;
      destX = pathX[pathIndex].toDouble();
      destY = pathY[pathIndex].toDouble();
      faceDestination();
      setCharacterStateRunning;
      return;
    }
    state = CharacterState.Idle;
  }

  double get getAngleBetweenTarget {
    assert (target != null);
    return getAngleBetween(x, y, target!.x, target!.y);
  }
}
