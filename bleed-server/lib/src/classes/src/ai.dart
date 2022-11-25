import 'dart:typed_data';

import 'package:lemon_math/library.dart';

import 'package:bleed_server/gamestream.dart';

abstract class AI extends Character {
  static const AI_Path_Size = 80;

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
    required int weaponType,
    required int damage,
    required int team,
    required double speed,
    this.wanderRadius = 0,
  }): super(
      x: x,
      y: y,
      z: z,
      health: health,
      team: team,
      speed: speed,
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

  void clearPath() {
    pathIndex = -1;
  }

  void clearDest(){
    destX = x;
    destY = y;
  }

  void faceDestination() {
    faceAngle = getAngle(destX - x, destY - y);
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
}
