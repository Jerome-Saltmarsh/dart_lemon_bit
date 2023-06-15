

import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/common/src/capture_the_flag/src.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_gameobject_flag.dart';
import 'package:bleed_server/src/games/isometric/isometric_character_template.dart';
import 'package:bleed_server/src/games/isometric/isometric_collider.dart';
import 'package:bleed_server/src/games/isometric/isometric_position.dart';

import 'capture_the_flag_game.dart';


class CaptureTheFlagPlayerAI extends IsometricCharacterTemplate {
  static var _idCount = 0;

  var id = _idCount++;
  var _updatePathToTargetUpdate = 0;
  CaptureTheFlagAIRole role;
  CaptureTheFlagCharacterClass characterClass;
  late final CaptureTheFlagGame game;

  int get pathNodeIndex => path[pathIndex];

  IsometricPosition? targetPrevious;

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
      return;
    }
    if (heldBy == this) {
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

  @override
  void customUpdate() {
    if (deadOrBusy) return;



    final target = this.target;

    if (targetPrevious != target){
      targetPrevious = target;
      updatePathToTarget();
    }

    if (target != null) {
      if (pathIndex >= pathEnd) {
        updatePathToTarget();
      }
    } else {
      pathIndex = pathEnd;
    }

    _updatePathToTargetUpdate--;
    if (_updatePathToTargetUpdate == 0){
      updatePathToTarget();
      _updatePathToTargetUpdate = 100;
    }

    if (pathIndex < pathEnd) {
      followPath();
    }

    updateBehaviorTree();
  }

  void updatePathToTarget() {
    if (target == null){
      pathEnd = 0;
      pathIndex = 0;
      return;
    }
    setPathToIsometricPosition(game.scene, target!);
  }

  void followPath() {
    assert (pathIndex < pathEnd);
    final scene = game.scene;

    if (scene.getNodeIndexV3(this) == pathNodeIndex) {
      pathIndex++;
      if (pathIndex >= pathEnd){
        pathIndex = 0;
        pathEnd = 0;
      } else {
        pathNodeX = scene.getNodePositionX(pathNodeIndex);
        pathNodeY = scene.getNodePositionY(pathNodeIndex);
      }
    } else {
      faceXY(pathNodeX, pathNodeY);
      setCharacterStateRunning();
    }
  }

  void updateBehaviorTree(){

    // if (enemyWithinRange(50))
    //   return attackNearestEnemy();

    final target = this.target;
    if (target != null) {
      if (target is CaptureTheFlagGameObjectFlag){
        if (distanceFromPos2(target) < 100){
          face(target);
          setCharacterStateRunning();
          return;
        }
      }

      if (isEnemy(target)){
        if (distanceFromPos2(target) < 50){
          face(target);
          attackMelee();
          return;
        }
      }
    }

    if (holdingFlagAny())
      return moveToBaseOwn();

    if (role == CaptureTheFlagAIRole.Offense) {
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
    if (enemyWithinRange(100))
      return attackNearestEnemy();
    if (enemyFlagCapturable)
      return captureEnemyFlag();


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
  }

  void moveToBaseOwn(){
    target = baseOwn;
  }

  void attackMelee(){
    game.characterAttackMelee(this);
  }
}

enum CaptureTheFlagAIRole {
  Defense,
  Offense,
}
