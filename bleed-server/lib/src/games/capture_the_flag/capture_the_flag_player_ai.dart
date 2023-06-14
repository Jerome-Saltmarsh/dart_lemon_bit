

import 'dart:typed_data';

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

  static const Max_Path_Length = 10;
  final path = Uint32List(Max_Path_Length);

  static final visitedNodes = Uint32List(10000);
  static var visitedNodesIndex = 0;

  var pathIndex = 0;
  var pathEnd = 0;

  var targetIndex = 0;
  var targetIndexRow = 0;
  var targetIndexColumn = 0;

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

  bool isVisited(int index){
    for (var i = 0; i < visitedNodesIndex; i++){
      if (visitedNodes[i] == index) {
        return true;
      }
    }
    return false;
  }

  bool visitNode(int index){
     if (index == targetIndex) {
       return true;
     }

     if (index < 0) return false;

     final nodeOrientation = game.scene.nodeOrientations[index];
     if (nodeOrientation != NodeOrientation.None) return false;

     if (isVisited(index)) return false;
     visitedNodes[visitedNodesIndex] = index;
     visitedNodesIndex++;

     final cachePathIndex = pathIndex;
     path[pathIndex] = index;
     pathIndex++;

     if (pathIndex >= Max_Path_Length) return true;

     final scene = game.scene;

     final indexRow = scene.getNodeIndexRow(index);
     if (indexRow < targetIndexRow){
       if (visitNode(index + scene.gridColumns)){
         return true;
       }
       // if that path fails, then cut the path back to a previous spot
       pathIndex = cachePathIndex;
     } else if (indexRow > targetIndexRow){
       if (visitNode(index - scene.gridColumns)){
         return true;
       }
       pathIndex = cachePathIndex;
     }

     final indexColumn = scene.getNodeIndexColumn(index);
     if (indexColumn < targetIndexColumn){
       if (visitNode(index + scene.gridRows)){
         return true;
       }
       pathIndex = cachePathIndex;
     } else if (indexColumn > targetIndexColumn){
       if (visitNode(index - scene.gridRows)){
         return true;
       }
       pathIndex = cachePathIndex;
     }
     return false;
  }

  @override
  void customUpdate() {
    if (deadOrBusy) return;

    final target = this.target;

    if (target != null && pathIndex >= pathEnd) {
      targetIndex = game.scene.getNodeIndexV3(target);
      targetIndexRow = target.indexRow;
      targetIndexColumn = target.indexColumn;
      updatePath();
    }

    if (pathIndex < pathEnd) {
      final scene = game.scene;
      final pathNodeIndex = path[pathIndex];
      final pathNodeX = scene.getNodePositionX(pathNodeIndex);
      final pathNodeY = scene.getNodePositionY(pathNodeIndex);
      final pathNodeZ = scene.getNodePositionZ(pathNodeIndex);
      if (withinDistance(pathNodeX, pathNodeY, pathNodeZ, 5.0)) {
        pathIndex++;
      } else {
        faceXY(pathNodeX, pathNodeY);
        setCharacterStateRunning();
      }
    } else {
      setCharacterStateIdle();
    }

    if (holdingFlagAny())
      return moveToBaseOwn();

    if (role == CaptureTheFlagAIRole.Offense){
      updateRoleOffense();
    } else {
      updateRoleDefense();
    }
  }

  void updatePath() {
    visitedNodesIndex = 0;
    pathIndex = 0;
    pathEnd = 0;
    if (visitNode(game.scene.getNodeIndexV3(this))){
      pathEnd = pathIndex;
      pathIndex = 0;
    } else {
      pathIndex = 0;
      pathEnd = 0;
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
