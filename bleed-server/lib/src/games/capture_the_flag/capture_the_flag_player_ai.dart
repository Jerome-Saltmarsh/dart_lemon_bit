

import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/common/src/capture_the_flag/src.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_gameobject_flag.dart';
import 'package:bleed_server/src/games/isometric/isometric_character.dart';
import 'package:bleed_server/src/games/isometric/isometric_character_template.dart';
import 'package:bleed_server/src/games/isometric/isometric_collider.dart';
import 'package:bleed_server/src/games/isometric/isometric_position.dart';
import 'package:lemon_math/functions/adjacent.dart';
import 'package:lemon_math/functions/opposite.dart';

import 'capture_the_flag_game.dart';


class CaptureTheFlagPlayerAI extends IsometricCharacterTemplate {
  static var _idCount = 0;

  var viewRange = 500.0;
  var id = _idCount++;
  CaptureTheFlagAIRole role;
  CaptureTheFlagCharacterClass characterClass;
  late final CaptureTheFlagGame game;
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
  int get nodeIndex => game.scene.getNodeIndexV3(this);
  int get pathNodeIndex => path[pathIndex];
  double get destinationDistanceSquared => getDistanceSquaredXYZ(destinationX, destinationY, destinationZ);

  bool get isTeamRed => team == CaptureTheFlagTeam.Red;
  bool get isTeamBlue => team == CaptureTheFlagTeam.Blue;

  IsometricPosition get baseOwn => isTeamRed ? game.baseRed : game.baseBlue;
  IsometricPosition get baseEnemy => isTeamRed ? game.baseBlue : game.baseRed;

  CaptureTheFlagGameObjectFlag get flagOwn => isTeamRed ? game.flagRed : game.flagBlue;
  CaptureTheFlagGameObjectFlag get flagEnemy => isTeamRed ? game.flagBlue : game.flagRed;

  IsometricPosition get flagSpawnOwn => game.getFlagSpawn(flagOwn);

  double get baseOwnDistance => getDistance3(baseOwn);
  double get baseEnemyDistance => getDistance3(baseEnemy);

  void captureFlag(CaptureTheFlagGameObjectFlag flag){

    if (flag.statusRespawning) {
       throw Exception('cannot capture flag as it is respawning');
    }

    final heldBy = flag.heldBy;
    if (heldBy == null){
      target = heldBy;
      return;
    }
    if (heldBy == this) {
      target = baseOwn;
      return;
    }
    if (isEnemy(heldBy)){
      target = heldBy;
      return;
    }

    if (isAlly(heldBy)){
      target = heldBy;
      return;
    }

    throw Exception();
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

    perceive();
    decide();
    execute();
  }

  void perceive(){

  }

  void decide(){

    if (holdingFlagAny)
      return runToBaseOwn();

    if (roleOffensive)
      return behaveDefensively();

    if (roleDefensive)
      return behaveOffensively();
  }

  void execute() {
    updatePathIndexAndDestination();

    if (enemyTargetAttackable)
      return attackTargetEnemy();
    if (!atDestination) {
      return runToDestination();
    }
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

  void updatePathToTarget() {
    if (target == null){
      pathEnd = 0;
      pathIndex = 0;
      return;
    }
    if (indexZ != 1) return;
    setPathToIsometricTarget();
  }

  void setPathToIsometricTarget() {
    final target = this.target;
    if (target == null) return;
    setPathToNodeIndex(game.scene, game.scene.getNodeIndexV3(target));
  }

  double getDestinationDistanceSquared () =>
      getDistanceSquaredXYZ(destinationX, destinationY, z);


  void updatePathIndexAndDestination() {

    final target = this.target;

    if (targetPrevious != target){
      targetPrevious = target;
      updatePathToTarget();
    }
    if (pathIndex >= pathEnd) {
      updatePathToTarget();
    }


    if (target == null) return;

    if (withinRadius(target, Node_Size)){
      pathEnd = 0;
      pathIndex = 0;
      destinationX = target.x;
      destinationY = target.y;
      return;
    }

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

  bool get targetIsAlliedCharacter => target is IsometricCharacter && targetIsAlly;

  void protectAllyTarget(){

  }

  void protectAllyCarryingFlagOwn(){

     if (flagOwnFurtherThan200()){
        return targetFlagOwn();
     }
     if (enemyWithinRange(200))
       return attackNearestEnemy();

     setCharacterStateIdle();
  }

  bool flagOwnFurtherThan200() => !withinRadius(flagOwn, 200);

  void targetFlagOwn() {
    target = flagOwn;
  }

  void behaveOffensively(){
    if (flagOwnCapturedByEnemy)
      return captureFlagOwn();
    if (flagOwnCapturedByAlly)
      return protectAllyCarryingFlagOwn();
    if (flagOwnDropped)
      return captureFlagOwn();
    if (awayFromFlagOwnSpawn)
      return defendFlagOwnSpawn();
    if (enemyWithinViewRange)
      return attackNearestEnemy();

    setCharacterStateIdle();
  }


  void defendFlagOwnSpawn() {
    target = flagSpawnOwn;
  }

  void behaveDefensively() {
    if (enemyFlagRespawning)
      return behaveOffensively();

    if (enemyWithinViewRange)
      return attackNearestEnemy();
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

  bool get enemyFlagCapturable => enemyFlagStatusAtBase || enemyFlagStatusDropped;

  bool get roleOffensive => role == CaptureTheFlagAIRole.Offense;
  bool get roleDefensive => role == CaptureTheFlagAIRole.Defense;

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

  bool get enemyWithinViewRange => enemyWithinRange(viewRange);
  bool get flagOwnCapturedByEnemy => flagOwn.status == CaptureTheFlagFlagStatus.Carried_By_Enemy;
  bool get flagOwnCapturedByAlly => flagOwn.status == CaptureTheFlagFlagStatus.Carried_By_Allie;
  bool get flagOwnDropped => flagOwn.status == CaptureTheFlagFlagStatus.Dropped;
  bool get awayFromFlagOwnSpawn => !withinRadius(flagSpawnOwn, 100);
  bool get enemyFlagRespawning => flagEnemy.status == CaptureTheFlagFlagStatus.Respawning;
  bool get holdingFlagAny => holdingFlagEnemy || holdingFlagOwn;
  bool get holdingFlagEnemy => flagEnemy.heldBy == this;
  bool get holdingFlagOwn => flagOwn.heldBy == this;
  bool get enemyFlagStatusAtBase => flagEnemy.status == CaptureTheFlagFlagStatus.At_Base;
  bool get enemyFlagStatusDropped => flagEnemy.status == CaptureTheFlagFlagStatus.Dropped;

  // actions
  void captureEnemyFlag() {
    target = flagEnemy;
  }

  void runToBaseOwn(){
    target = baseOwn;
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

  void onDeath() {
    pathIndex = 0;
    pathEnd = 0;
    target = null;
    targetPrevious = null;
  }
}

enum CaptureTheFlagAIRole {
  Defense,
  Offense,
}
