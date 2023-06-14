

import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/common/src/capture_the_flag/src.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_gameobject_flag.dart';
import 'package:bleed_server/src/games/isometric/isometric_character_template.dart';
import 'package:bleed_server/src/games/isometric/isometric_collider.dart';
import 'package:bleed_server/src/games/isometric/isometric_position.dart';

import 'capture_the_flag_game.dart';


class CaptureTheFlagPlayerAI extends IsometricCharacterTemplate {
  late final CaptureTheFlagGame game;
  CaptureTheFlagAIRole role;
  CaptureTheFlagCharacterClass characterClass;


  CaptureTheFlagPlayerAI({
    required this.game,
    required super.team,
    required this.characterClass,
    this.role = CaptureTheFlagAIRole.Defense,
  }) : super(
    health: 10,
    weaponType: ItemType.Empty,
    damage: 1,
    x: ((team == CaptureTheFlagTeam.Red) ? game.baseRed : game.baseBlue).x,
    y: ((team == CaptureTheFlagTeam.Red) ? game.baseRed : game.baseBlue).y,
    z: ((team == CaptureTheFlagTeam.Red) ? game.baseRed : game.baseBlue).z,
  ) {
    if (isTeamRed) {
      bodyType = ItemType.Body_Shirt_Red;
      legsType = ItemType.Legs_Red;
    } else {
      bodyType = ItemType.Body_Shirt_Blue;
      legsType = ItemType.Legs_Blue;
    }

    // behaviorTree = SelectorNode([
    //   SequenceNode([
    //     ConditionNode(holdingFlagAny),
    //     ActionNode(moveToBaseOwn),
    //   ]),
    //   SequenceNode([
    //     ConditionNodeAny([enemyFlagStatusAtBase, enemyFlagStatusDropped]),
    //     ActionNode(captureEnemyFlag),
    //   ]),
    //   SequenceNode([
    //     ConditionNode(flagOwnDropped),
    //     ActionNode(captureFlagOwn),
    //   ]),
    //   SequenceNode([
    //     ConditionNode(enemyWithinRange500),
    //     ActionNode(attackNearestEnemy),
    //   ]),
    //   ActionNode(setCharacterStateIdle),
    // ]);
  }

  bool get isTeamRed => team == CaptureTheFlagTeam.Red;
  bool get isTeamBlue => team == CaptureTheFlagTeam.Blue;

  IsometricPosition get baseOwn => isTeamRed ? game.baseRed : game.baseBlue;
  IsometricPosition get baseEnemy => isTeamRed ? game.baseBlue : game.baseRed;

  CaptureTheFlagGameObjectFlag get flagOwn => isTeamRed ? game.flagRed : game.flagBlue;
  CaptureTheFlagGameObjectFlag get flagEnemy => isTeamRed ? game.flagBlue : game.flagRed;

  double get baseOwnDistance => getDistance3(baseOwn);
  double get baseEnemyDistance => getDistance3(baseEnemy);

  void captureFlag(CaptureTheFlagGameObjectFlag flag){
    if (flag.statusRespawning) {
      setCharacterStateIdle();
      return;
    }

    final heldBy = flag.heldBy;
    if (heldBy == null){
      target = flag;
      // face(flag);
      // setCharacterStateRunning();
      return;
    }
    if (heldBy == this) {
      // face(baseOwn);
      // setCharacterStateRunning();
      target = baseOwn;
      return;
    }
    setCharacterStateIdle();
  }

  void captureFlagOwn(){
    captureFlag(flagOwn);
  }

  void attackNearestEnemy(){
    target = getNearestEnemy();
     // if (nearestEnemy == null) return;
     // face(nearestEnemy);
     // target = nearestEnemy;
     // if (withinAttackRange(nearestEnemy)) {
     //    attackMelee();
     // } else{
     //    setCharacterStateRunning();
     // }
  }

  IsometricCollider? getNearestEnemy(){
    IsometricCollider? nearestEnemy;
    var nearestEnemyDistanceSquared = 10000.0 * 10000.0;
    for (final character in game.characters){
        if (!isEnemy(character)) continue;
        final distanceSquared = getDistanceIsoPosSquared(character);
        if (distanceSquared > nearestEnemyDistanceSquared) continue;
        nearestEnemyDistanceSquared = distanceSquared;
        nearestEnemy = character;
    }
    return nearestEnemy;
  }

  void captureFlagEnemy(){
    captureFlag(flagEnemy);
  }

  void idle(){
    setCharacterStateIdle();
  }

  @override
  void customUpdate() {
    if (deadOrBusy) return;

    final target = this.target;

    if (target != null && pathIndex >= pathEnd) {
      updatePath(game.scene, game.scene.getNodeIndexV3(target));
    }

    if (pathIndex < pathEnd) {
      followPath();
    } else {
      setCharacterStateIdle();
    }

    updateBehaviorTree();
  }

  void followPath() {
    final scene = game.scene;
    final pathNodeIndex = path[pathIndex];
    assert (scene.nodeOrientations[pathNodeIndex] == NodeOrientation.None);
    final pathNodeX = scene.getNodePositionX(pathNodeIndex);
    final pathNodeY = scene.getNodePositionY(pathNodeIndex);
    final pathNodeZ = scene.getNodePositionZ(pathNodeIndex);
    if (withinDistance(pathNodeX, pathNodeY, pathNodeZ, 2.0)) {
      pathIndex++;
    } else {
      faceXY(pathNodeX, pathNodeY);
      setCharacterStateRunning();
    }
  }

  void updateBehaviorTree(){

    // if (enemyWithinRange(50))
    //   return attackNearestEnemy();


    if (holdingFlagAny())
      return moveToBaseOwn();

    if (role == CaptureTheFlagAIRole.Offense){
      updateRoleOffense();
    } else {
      updateRoleDefense();
    }
  }

  void updateRoleDefense(){
    if (flagOwnDropped())
      return captureFlagOwn();
    if (enemyWithinRange(500))
      return attackNearestEnemy();

    setCharacterStateIdle();
  }

  void updateRoleOffense() {
    if (enemyFlagCapturable)
      return captureEnemyFlag();
    if (enemyWithinRange(500))
      return attackNearestEnemy();

    setCharacterStateIdle();
  }

  bool enemyWithinRange(double range){
     final distanceSquared = range * range;
     final characters = game.characters;
     for (final character in characters) {
        if (!isEnemy(character)) continue;
        final characterDistanceSquared = getDistanceIsoPosSquared(character);
        if (characterDistanceSquared > distanceSquared) continue;
        return true;
     }
     return false;
  }
  bool get enemyFlagCapturable => enemyFlagStatusAtBase() || enemyFlagStatusDropped();

  bool flagOwnDropped() => flagOwn.status == CaptureTheFlagFlagStatus.Dropped;
  bool holdingFlagAny() => holdingFlagEnemy() || holdingFlagOwn();
  bool holdingFlagEnemy() => flagEnemy.heldBy == this;
  bool holdingFlagOwn() => flagOwn.heldBy == this;
  bool enemyFlagStatusAtBase() => flagEnemy.status == CaptureTheFlagFlagStatus.At_Base;
  bool enemyFlagStatusDropped() => flagEnemy.status == CaptureTheFlagFlagStatus.Dropped;
  bool isEnemyFlagCaptured() => flagEnemy.status == CaptureTheFlagFlagStatus.Carried_By_Enemy;
  bool enemyFlagCaptured() => flagEnemy.status == CaptureTheFlagFlagStatus.Carried_By_Enemy;
  bool enemyFlagRespawning() => flagEnemy.status == CaptureTheFlagFlagStatus.Respawning;
  bool isEnemyFlagNear() => getDistance3(flagEnemy) < 500;
  bool isEnemyNearBase() => getDistance3(baseEnemy) < 500;
  bool isFriendlyFlagCaptured() => flagOwn.status == CaptureTheFlagFlagStatus.Carried_By_Enemy;

  void captureEnemyFlag() {
    target = flagEnemy;
    // face(flagEnemy);
    // setCharacterStateRunning();
  }

  void moveToBaseOwn(){
    target = baseOwn;
    // face(baseOwn);
    // setCharacterStateRunning();
  }

  void attackMelee(){
    game.characterAttackMelee(this);
  }
}

enum CaptureTheFlagAIRole {
  Defense,
  Offense,
}
