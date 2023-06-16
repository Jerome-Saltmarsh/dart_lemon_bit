

import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/common/src/capture_the_flag/src.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_gameobject_flag.dart';
import 'package:bleed_server/src/games/isometric/isometric_character_template.dart';
import 'package:bleed_server/src/games/isometric/isometric_collider.dart';
import 'package:bleed_server/src/games/isometric/isometric_position.dart';
import 'package:lemon_math/functions/adjacent.dart';
import 'package:lemon_math/functions/opposite.dart';

import 'capture_the_flag_game.dart';


class CaptureTheFlagPlayerAI extends IsometricCharacterTemplate {
  static var _idCount = 0;

  var id = _idCount++;
  CaptureTheFlagAIRole role;
  CaptureTheFlagCharacterClass characterClass;
  late final CaptureTheFlagGame game;

  int get nodeIndex => game.scene.getNodeIndexV3(this);
  int get pathNodeIndex => path[pathIndex];
  double get destinationDistanceSquared => getDistanceSquaredXYZ(destinationX, destinationY, destinationZ);

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

    switch (characterClass) {
      case CaptureTheFlagCharacterClass.scout:
        weaponType = ItemType.Weapon_Ranged_Bow;
        break;
      case CaptureTheFlagCharacterClass.knight:
        weaponType = ItemType.Weapon_Melee_Sword;
        break;
      default:
        break;
    }

    updateWeaponRange();
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

  void targetNearestEnemy(){
    target = getNearestEnemy();
  }

  IsometricCollider? getNearestEnemy(){
    IsometricCollider? nearestEnemy;
    var nearestEnemyDistanceSquared = 10000.0 * 10000.0;
    for (final character in game.characters){
        if (!isEnemy(character)) continue;
        final distanceSquared = getDistanceSquared(character);
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

    // TODO Optimize
    if (targetPrevious != target){
      targetPrevious = target;
      updatePath();
    }

    if (pathIndex >= pathEnd) {
      updatePath();
    }

    updatePathIndexAndDestination();

    if (!atDestination) {
      runToDestination();
    }

    updateBehaviorTree();
  }

  bool get enemyVeryCloseBy {
    final nearestEnemy = getNearestEnemy();
    if (nearestEnemy == null) return false;
    return getDistanceSquared(nearestEnemy) < 10000;
  }

  void runToDestination(){
    faceDestination();
    setCharacterStateRunning();
  }

  void faceDestination() {
    faceXY(destinationX, destinationY);
  }

  void updatePath() {
    if (target == null){
      pathEnd = 0;
      pathIndex = 0;
      return;
    }
    if (indexZ != 1) return;
    setPathToIsometricPosition(game.scene, target!);
  }

  double getDestinationDistanceSquared () =>
      getDistanceSquaredXYZ(destinationX, destinationY, z);


  void updatePathIndexAndDestination() {
    if (pathIndex >= pathEnd) return;
    if (!atDestination) return;
    pathIndex++;
    if (pathIndex >= pathEnd) {
      pathIndex = 0;
      pathEnd = 0;
      destinationX = x;
      destinationY = y;
      destinationZ = z;
    } else {
      final scene = game.scene;
      destinationX = scene.getNodePositionX(pathNodeIndex);
      destinationY = scene.getNodePositionY(pathNodeIndex);
    }
  }

  bool get atDestination => getDestinationDistanceSquared() < 150;

  void updateBehaviorTree(){

    if (enemyVeryCloseBy) {
      targetNearestEnemy();
    }

    if (enemyTargetAttackable)
      return attackTargetEnemy();

    if (holdingFlagAny)
      return runToBaseOwn();

    if (roleOffensive) {
      updateRoleOffense();
    } else {
      updateRoleDefense();
    }
  }


  void updateRoleDefense(){
    if (flagOwnDropped())
      return captureFlagOwn();
    if (enemyWithinRange(500))
      return targetNearestEnemy();

    setCharacterStateIdle();
  }

  void updateRoleOffense() {
    if (enemyWithinRange(500))
      return targetNearestEnemy();
    if (enemyFlagCapturable)
      return captureEnemyFlag();


    setCharacterStateIdle();
  }

  void attackTargetEnemy(){
    assert (target != null);
    face(target!);
    useWeapon();
    setCharacterStateIdle();
  }

  bool enemyWithinRange(double range){
     final distanceSquared = range * range;
     final characters = game.characters;
     for (final character in characters) {
        if (!isEnemy(character)) continue;
        final characterDistanceSquared = getDistanceSquared(character);
        if (characterDistanceSquared > distanceSquared) continue;
        return true;
     }
     return false;
  }
  bool get enemyFlagCapturable => enemyFlagStatusAtBase() || enemyFlagStatusDropped();

  bool get roleOffensive => role == CaptureTheFlagAIRole.Offense;

  bool get enemyTargetAttackable {
    final target = this.target;
    if (target == null) return false;
    if (target is! IsometricCollider) return false;
    if (!target.hitable) return false;
    if (!targetIsEnemy) return false;
    if (!enemyTargetWithinAttackRange) return false;
    return targetIsPerceptible;
  }

  bool get targetIsPerceptible {
    final target = this.target;
    if (target == null) return false;
    final distance = getDistance3(target);
    final jumpSize = Node_Size_Quarter;
    final jumps = distance ~/ jumpSize;

    var positionX = x;
    var positionY = y;
    var angle = target.getAngle(this);
    final velX = getAdjacent(angle, jumpSize);
    final velY = getOpposite(angle, jumpSize);

    final scene = game.scene;

    for (var i = 0; i < jumps; i++){
      positionX += velX;
      positionY += velY;
      final nodeOrientation = scene.getNodeOrientationXYZ(positionX, positionY, z);
      if (nodeOrientation != NodeOrientation.None){
        return false;
      }
    }
    return true;
  }

  bool get enemyTargetWithinAttackRange {
    final target = this.target;
    if (target == null) return false;
    if (!isEnemy(target)) return false;
    return getDistanceSquared(target) < weaponRangeSquared;
  }

  bool flagOwnDropped() => flagOwn.status == CaptureTheFlagFlagStatus.Dropped;
  bool get holdingFlagAny => holdingFlagEnemy() || holdingFlagOwn();
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

  void runToBaseOwn(){
    target = baseOwn;
  }

  void attackMelee(){
    game.characterAttackMelee(this);
  }

  @override
  void onWeaponTypeChanged() {
     updateWeaponRange();
  }

  void updateWeaponRange() {
    if (weaponType == ItemType.Weapon_Ranged_Bow){
      weaponRange = 300;
    }
    if (weaponType == ItemType.Weapon_Melee_Sword){
      weaponRange = 60;
    }
  }

  void useWeapon() => game.characterUseWeapon(this);
}

enum CaptureTheFlagAIRole {
  Defense,
  Offense,
}
