

import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/isometric/src.dart';
import 'package:lemon_math/functions/adjacent.dart';
import 'package:lemon_math/functions/opposite.dart';

import 'capture_the_flag_game.dart';
import 'capture_the_flag_gameobject_flag.dart';


class CaptureTheFlagAI extends IsometricCharacterTemplate {

  var slowed = false;
  var slowedDuration = 0;

  var decision = CaptureTheFlagAIDecision.Idle;
  var viewRange = 500.0;
  CaptureTheFlagAIRole role;
  IsometricPosition? targetPrevious;
  late int id;
  late final CaptureTheFlagGame game;

  CaptureTheFlagAI({
    required this.game,
    required super.team,
    required super.weaponType,
    this.role = CaptureTheFlagAIRole.Defense,
  }) : super(
    health: 10,
    damage: 1,
    x: ((team == CaptureTheFlagTeam.Red) ? game.baseRed : game.baseBlue).x,
    y: ((team == CaptureTheFlagTeam.Red) ? game.baseRed : game.baseBlue).y,
    z: ((team == CaptureTheFlagTeam.Red) ? game.baseRed : game.baseBlue).z,
  ) {
    id = game.generateUniqueId();
    if (isTeamRed) {
      bodyType = ItemType.Body_Shirt_Red;
      legsType = ItemType.Legs_Red;
    } else {
      bodyType = ItemType.Body_Shirt_Blue;
      legsType = ItemType.Legs_Blue;
    }
  }

  bool get shouldRunToDestination =>
      !deadBusyOrWeaponStateBusy && getDestinationDistanceSquared() > 80;

  bool get targetIsAlliedCharacter => target is IsometricCharacter && targetIsAlly;
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

  bool get flagEnemyCapturable => flagEnemy.statusAtBase || flagEnemy.statusDropped;


  bool get enemyFlagCapturable => enemyFlagStatusAtBase || enemyFlagStatusDropped;
  bool get roleOffensive => role == CaptureTheFlagAIRole.Offense;
  bool get roleDefensive => role == CaptureTheFlagAIRole.Defense;

  bool get shouldAttackTargetEnemy {
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

  bool get closeToFlagOwn => withinRadiusPosition(flagOwn, 250);
  bool get enemyWithinViewRange => enemyWithinRange(viewRange);
  bool get flagOwnCapturedByEnemy => flagOwn.status == CaptureTheFlagFlagStatus.Carried_By_Enemy;
  bool get flagOwnCapturedByAlly => flagOwn.status == CaptureTheFlagFlagStatus.Carried_By_Ally;
  bool get flagOwnDropped => flagOwn.status == CaptureTheFlagFlagStatus.Dropped;
  bool get awayFromFlagOwnSpawn => !withinRadiusPosition(flagSpawnOwn, 100);
  bool get flagOwnRespawning => flagOwn.status == CaptureTheFlagFlagStatus.Respawning;
  bool get flagEnemyRespawning => flagEnemy.status == CaptureTheFlagFlagStatus.Respawning;
  bool get holdingFlagAny => holdingFlagEnemy || holdingFlagOwn;
  bool get holdingFlagEnemy => flagEnemy.heldBy == this;
  bool get holdingFlagOwn => flagOwn.heldBy == this;
  bool get enemyFlagStatusAtBase => flagEnemy.status == CaptureTheFlagFlagStatus.At_Base;
  bool get enemyFlagStatusDropped => flagEnemy.status == CaptureTheFlagFlagStatus.Dropped;

  bool get shouldIncrementPathIndex => nodeIndex == pathNodeIndex;

  bool get arrivedAtPathEnd => pathIndex <= 0;

  bool get shouldUpdatePath {
    if (indexZ != 1) return false;

    if (targetPrevious != target) {
      targetPrevious = target;
      return true;
    }
    if (target == null) return false;

    if (pathIndex <= 0) {
      return game.scene.getNodeIndexV3(target!) != game.scene.getNodeIndexV3(this);
    }

    if (arrivedAtPathEnd) {
      return true;
    }

    return targetIndexChanged;
  }

  bool get targetIndexChanged => target != null && game.scene.getNodeIndexV3(target!) != targetIndex;

  bool get shouldSetDestinationToTarget {
    final target = this.target;
    if (target == null) return false;
    return withinRadiusPosition(target, Node_Size);
  }

  @override
  double get runSpeed => slowed ? super.runSpeed * 0.5 : super.runSpeed;

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

  CaptureTheFlagAIDecision getDecision(){

    if (holdingFlagAny)
      return CaptureTheFlagAIDecision.Run_To_Base_Own;

    if (flagOwnDropped && flagOwnWithinRadius(300))
      return CaptureTheFlagAIDecision.Capture_Flag_Own;

    if (flagEnemyCapturable && flagEnemyWithinRadius(300))
      return CaptureTheFlagAIDecision.Capture_Flag_Enemy;

    if (roleOffensive)
      return getDecisionOffensive();

    if (roleDefensive)
      return getDecisionDefensive();

    return CaptureTheFlagAIDecision.Idle;
  }

  @override
  void customUpdate() {
    if (deadOrBusy) return;

    if (slowed) {
       slowedDuration--;
       if (slowedDuration <= 0){
         slowed = false;
       }
    }

    decision = getDecision();
    executeDecision();
    updatePathIndexAndDestination();
  }

  void updatePath() {
    final target = this.target;
    if (target == null) {
      pathIndex = 0;
      pathStart = 0;
      return;
    }
    setPathToNodeIndex(game.scene, game.scene.getNodeIndexV3(target));
  }

  void updatePathIndexAndDestination() {

    // if (shouldAttackTargetEnemy) {
    //   attackTargetEnemy();
    // }
    if (shouldUpdatePath) {
      updatePath();
    }

    updateDestinationToPathNodeIndex();

    // if (shouldSetDestinationToTarget) {
    //   setDestinationToTarget();
    // }
    // if (shouldRunToDestination) {
    //   runToDestination();
    // }
    // if (shouldIncrementPathIndex) {
    //   incrementPathIndex();
    // }
  }

  void incrementPathIndex() {
    pathIndex--;
    if (pathIndex <= 0) return;
    updateDestinationToPathNodeIndex();
  }

  void updateDestinationToPathNodeIndex() {
    if (pathIndex <= 0) return;
    final scene = game.scene;
    destinationX = scene.getNodePositionX(pathNodeIndex);
    destinationY = scene.getNodePositionY(pathNodeIndex);
  }

  void executeDecision() {

    switch (decision){
      case CaptureTheFlagAIDecision.Idle:
        idle();
        break;
      case CaptureTheFlagAIDecision.Capture_Flag_Own:
        final heldBy = flagOwn.heldBy;
        if (heldBy == null) {
          target = flagOwn;
          return;
        }
        if (isEnemy(heldBy)){
          target = heldBy;
          return;
        }
        if (awayFromFlagOwnSpawn){
          target = flagOwn;
        }
        break;
      case CaptureTheFlagAIDecision.Capture_Flag_Enemy:
        target = flagEnemy;
        break;
      case CaptureTheFlagAIDecision.Attack_Nearest_Enemy:
        target = getNearestEnemy();
        if (target == null){
          idle();
          break;
        }
        break;
      case CaptureTheFlagAIDecision.Run_To_Base_Own:
        target = baseOwn;
      case CaptureTheFlagAIDecision.Defend_Flag_Spawn_Own:
        target = flagSpawnOwn;
        break;
      case CaptureTheFlagAIDecision.Run_To_Flag_Own:
        if (flagOwnRespawning) {
          target = flagSpawnOwn;
          break;
        }
        if (withinRadiusPosition(flagOwn, 50)) {
          idle();
        } else {
          target = flagOwn;
        }
        break;
      default:
        throw Exception('not implemented');
    }
  }

  void runToDestination(){
    faceDestination();
    setCharacterStateRunning();
  }

  void faceDestination() {
    faceXY(destinationX, destinationY);
  }

  double getDestinationDistanceSquared () =>
      getDistanceSquaredXYZ(destinationX, destinationY, z);


  void targetFlagOwn() {
    target = flagOwn;
  }

  CaptureTheFlagAIDecision getDecisionDefensive() {

    if (flagOwnCapturedByEnemy)
      return CaptureTheFlagAIDecision.Capture_Flag_Own;
    if (flagOwnCapturedByAlly) {
      if (closeToFlagOwn) {
        return CaptureTheFlagAIDecision.Attack_Nearest_Enemy;
      }
      return CaptureTheFlagAIDecision.Run_To_Flag_Own;
    }

    if (flagOwnDropped)
      return CaptureTheFlagAIDecision.Capture_Flag_Own;
    if (awayFromFlagOwnSpawn)
      return CaptureTheFlagAIDecision.Defend_Flag_Spawn_Own;
    if (enemyWithinViewRange)
      return CaptureTheFlagAIDecision.Attack_Nearest_Enemy;

    return CaptureTheFlagAIDecision.Idle;
  }

  CaptureTheFlagAIDecision getDecisionOffensive() {
    if (flagEnemyRespawning)
      return getDecisionDefensive();
    if (enemyWithinViewRange)
      return CaptureTheFlagAIDecision.Attack_Nearest_Enemy;
    if (enemyFlagCapturable)
      return CaptureTheFlagAIDecision.Capture_Flag_Enemy;

    return CaptureTheFlagAIDecision.Idle;
  }

  void idle() {
    setCharacterStateIdle();
    destinationX = x;
    destinationY = y;
    destinationZ = z;
  }

  void attackTargetEnemy(){
    assert (target != null);
    idle();
    face(target!);
    useWeapon();
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

  @override
  void onWeaponTypeChanged() {
    weaponRange = game.getWeaponTypeRange(weaponType);
  }

  void useWeapon() => game.characterUseWeapon(this);

  void toggleRole() => role = roleDefensive ? CaptureTheFlagAIRole.Offense : CaptureTheFlagAIRole.Defense;

  bool flagOwnWithinRadius(double radius) =>
      flagOwnRespawning ? false : withinRadiusPosition(flagOwn, radius);

  bool flagEnemyWithinRadius(double radius) =>
      flagEnemyRespawning ? false : withinRadiusPosition(flagEnemy, radius);

  void setDestinationToTarget() {
    final target = this.target;
    if (target == null) return;
    destinationX = target.x;
    destinationY = target.y;
    destinationZ = target.z;
  }

}

