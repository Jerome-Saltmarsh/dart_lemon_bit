

import 'package:gamestream_server/common/src.dart';
import 'package:gamestream_server/isometric/src.dart';

import 'capture_the_flag_game.dart';
import 'capture_the_flag_gameobject_flag.dart';


class CaptureTheFlagAI extends IsometricCharacter {

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
    characterType: CharacterType.Template,
    weaponRange: game.getWeaponTypeRange(weaponType),
    weaponDamage: game.getWeaponTypeDamage(weaponType),
    weaponCooldown: game.getWeaponCooldown(weaponType),
    x: ((team == CaptureTheFlagTeam.Red) ? game.baseRed : game.baseBlue).x,
    y: ((team == CaptureTheFlagTeam.Red) ? game.baseRed : game.baseBlue).y,
    z: ((team == CaptureTheFlagTeam.Red) ? game.baseRed : game.baseBlue).z,
  ) {
    id = game.generateUniqueId();
    if (isTeamRed) {
      bodyType = BodyType.Shirt_Red;
      legsType = LegType.Red;
    } else {
      bodyType = BodyType.Shirt_Blue;
      legsType = LegType.Blue;
    }
  }

  bool get targetIsAlliedCharacter => target is IsometricCharacter && targetIsAlly;

  bool get isTeamRed => team == CaptureTheFlagTeam.Red;

  bool get isTeamBlue => team == CaptureTheFlagTeam.Blue;

  IsometricPosition get baseOwn => isTeamRed ? game.baseRed : game.baseBlue;

  IsometricPosition get baseEnemy => isTeamRed ? game.baseBlue : game.baseRed;

  CaptureTheFlagGameObjectFlag get flagOwn => isTeamRed ? game.flagRed : game.flagBlue;

  CaptureTheFlagGameObjectFlag get flagEnemy => isTeamRed ? game.flagBlue : game.flagRed;

  IsometricPosition get flagSpawnOwn => game.getFlagSpawn(flagOwn);

  double get baseOwnDistance => getDistance(baseOwn);

  double get baseEnemyDistance => getDistance(baseEnemy);

  bool get flagEnemyCapturable => flagEnemy.statusAtBase || flagEnemy.statusDropped;

  bool get enemyFlagCapturable => enemyFlagStatusAtBase || enemyFlagStatusDropped;

  bool get roleOffensive => role == CaptureTheFlagAIRole.Offense;

  bool get roleDefensive => role == CaptureTheFlagAIRole.Defense;

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

  bool get targetIndexChanged {
    final target = this.target;
    if (target == null) return false;
    return game.scene.getIndexPosition(target) != pathTargetIndex;
  }

  @override
  double get runSpeed => slowed ? super.runSpeed * 0.5 : super.runSpeed;

  bool get shouldUpdateCharacterAction => !deadBusyOrWeaponStateBusy;

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
  void update() {
    super.update();
    if (deadOrBusy) return;

    if (slowed) {
       slowedDuration--;
       if (slowedDuration <= 0){
         slowed = false;
       }
    }

    decision = getDecision();
    final target = getTarget();
    this.target = target;

    if (target is CaptureTheFlagGameObjectFlag) {
      if (target.statusDropped) {
        if (targetWithinRadius(Node_Size)){
          faceTarget();
          setCharacterStateRunning();
        }
      }
    }


  }

  IsometricPosition? getTarget() {
    switch (decision) {
      case CaptureTheFlagAIDecision.Idle:
        return null;
      case CaptureTheFlagAIDecision.Capture_Flag_Own:
        final heldBy = flagOwn.heldBy;

        if (heldBy == null)
          return flagOwn;

        if (isEnemy(heldBy))
          return heldBy;

        if (awayFromFlagOwnSpawn)
          return flagOwn;

        return null;

      case CaptureTheFlagAIDecision.Capture_Flag_Enemy:
        return flagEnemy;

      case CaptureTheFlagAIDecision.Attack_Nearest_Enemy:
        return game.findNearestEnemy(this);

      case CaptureTheFlagAIDecision.Run_To_Base_Own:
         return baseOwn;

      case CaptureTheFlagAIDecision.Defend_Flag_Spawn_Own:
         return flagSpawnOwn;

      case CaptureTheFlagAIDecision.Run_To_Flag_Own:
        if (flagOwnRespawning)
          return flagSpawnOwn;

        if (withinRadiusPosition(flagOwn, 50))
          return null;

        return flagOwn;

      default:
        throw Exception('not implemented');
    }
  }

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

  void toggleRole() => role = roleDefensive ? CaptureTheFlagAIRole.Offense : CaptureTheFlagAIRole.Defense;

  bool flagOwnWithinRadius(double radius) =>
      flagOwnRespawning ? false : withinRadiusPosition(flagOwn, radius);

  bool flagEnemyWithinRadius(double radius) =>
      flagEnemyRespawning ? false : withinRadiusPosition(flagEnemy, radius);

}

