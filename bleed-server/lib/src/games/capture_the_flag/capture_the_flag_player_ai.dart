

import 'package:bleed_server/behavior_tree/src.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_flag_status.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_team.dart';
import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_gameobject_flag.dart';
import 'package:bleed_server/src/games/isometric/isometric_character_template.dart';
import 'package:bleed_server/src/games/isometric/isometric_position.dart';

import 'capture_the_flag_game.dart';
import 'capture_the_flag_player_ai_objective.dart';


class CaptureTheFlagPlayerAI extends IsometricCharacterTemplate {
  late final CaptureTheFlagGame game;
  var objective = CaptureTheFlagPlayerAIObjective.Capture_Flag_Own;

  late final BehaviorNode behaviorTree;

  CaptureTheFlagPlayerAI({
    required this.game,
    required super.team,
  }) : super(
    health: 10,
    weaponType: ItemType.Empty,
    damage: 1,
    x: ((team == CaptureTheFlagTeam.Red) ? game.baseRed : game.baseBlue).x,
    y: ((team == CaptureTheFlagTeam.Red) ? game.baseRed : game.baseBlue).y,
    z: ((team == CaptureTheFlagTeam.Red) ? game.baseRed : game.baseBlue).z,
  ) {
    if (isTeamRed){
      bodyType = ItemType.Body_Shirt_Red;
      legsType = ItemType.Legs_Red;
    } else {
      bodyType = ItemType.Body_Shirt_Blue;
      legsType = ItemType.Legs_Blue;
    }

    behaviorTree = SelectorNode([
      SequenceNode([
        ConditionNodeAny([holdingFlagEnemy, holdingFlagOwn]),
        ActionNode(moveToBaseOwn),
      ]),
      SequenceNode([
        ConditionNodeAny([enemyFlagStatusAtBase, enemyFlagStatusDropped]),
        ActionNode(captureEnemyFlag),
      ]),
      SequenceNode([
        ConditionNode(flagOwnDropped),
        ActionNode(captureFlagOwn),
      ]),
      ActionNode(setCharacterStateIdle),
    ]);
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
      face(flag);
      setCharacterStateRunning();
      return;
    }
    if (heldBy == this) {
      face(baseOwn);
      setCharacterStateRunning();
      return;
    }
    setCharacterStateIdle();
  }

  void captureFlagOwn(){
    captureFlag(flagOwn);
  }

  void captureFlagEnemy(){
    captureFlag(flagEnemy);
  }

  void idle(){
    setCharacterStateIdle();
  }


  CaptureTheFlagPlayerAIObjective getObjective(){

    if (healthPercentage < 0.25) return CaptureTheFlagPlayerAIObjective.Heal;

    if (flagEnemy.heldBy == this){
      return CaptureTheFlagPlayerAIObjective.Capture_Flag_Enemy;
    }

    if (flagOwn.heldBy == this){
      return CaptureTheFlagPlayerAIObjective.Capture_Flag_Own;
    }

    if (!flagOwn.statusRespawning && !flagOwn.statusAtBase){
      final flagOwnHeldBy = flagOwn.heldBy;
      if (flagOwnHeldBy == null || flagOwnHeldBy == this) {
        return CaptureTheFlagPlayerAIObjective.Capture_Flag_Own;
      }
    }

    if (!flagEnemy.statusRespawning){
      final flagHeldBy = flagEnemy.heldBy;
      if (flagHeldBy == null || flagHeldBy == this) {
        return CaptureTheFlagPlayerAIObjective.Capture_Flag_Enemy;
      }
    }

     return CaptureTheFlagPlayerAIObjective.Wait;
  }

  @override
  void customUpdate() {
    if (deadOrBusy) return;
    behaviorTree.execute();
  }

  bool flagOwnDropped() => flagOwn.status == CaptureTheFlagFlagStatus.Dropped;
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
    face(flagEnemy);
    setCharacterStateRunning();
  }

  void moveToBaseOwn(){
    face(baseOwn);
    setCharacterStateRunning();
  }

  void attack(){
      // characterAttackMelee(player);
    setCharacterStatePerforming(duration: 30);
  }
}