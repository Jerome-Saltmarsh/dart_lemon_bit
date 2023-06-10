

import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_flag_status.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_team.dart';
import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/src/games/isometric/isometric_character_template.dart';
import 'package:bleed_server/src/games/isometric/isometric_gameobject.dart';
import 'package:bleed_server/src/games/isometric/isometric_position.dart';

import 'capture_the_flag_game.dart';
import 'capture_the_flag_player_ai_objective.dart';


class CaptureTheFlagPlayerAI extends IsometricCharacterTemplate {
  late final CaptureTheFlagGame game;
  var objective = CaptureTheFlagPlayerAIObjective.Capture_Flag_Enemy;

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
  );

  bool get isTeamRed => team == CaptureTheFlagTeam.Red;
  bool get isTeamBlue => team == CaptureTheFlagTeam.Blue;

  IsometricPosition get baseOwn => isTeamRed ? game.baseRed : game.baseBlue;
  IsometricPosition get baseEnemy => isTeamRed ? game.baseBlue : game.baseRed;

  IsometricGameObject get flagOwn => isTeamRed ? game.flagRed : game.flagBlue;
  IsometricGameObject get flagEnemy => isTeamBlue ? game.flagBlue : game.flagRed;

  double get baseOwnDistance => getDistance3(baseOwn);
  double get baseEnemyDistance => getDistance3(baseEnemy);

  int get flagOwnStatus => isTeamRed ? game.flagRed.status : game.flagBlue.status;
  int get flagEnemyStatus => isTeamRed ? game.flagBlue.status : game.flagRed.status;

  void captureEnemyFlag(){
    final flagEnemyDistance = getDistance3(flagEnemy);

    if (flagEnemyDistance < 50){

    }
    face(flagEnemy);
    setCharacterStateRunning();
  }

  void idle(){
    setCharacterStateIdle();
  }

  @override
  void customUpdate() {

    switch (objective) {
      case CaptureTheFlagPlayerAIObjective.Capture_Flag_Enemy:
        switch (flagEnemyStatus) {
          case CaptureTheFlagFlagStatus.Dropped:
            captureEnemyFlag();
            break;
          case CaptureTheFlagFlagStatus.At_Base:
            captureEnemyFlag();
            break;
          case CaptureTheFlagFlagStatus.Carried_By_Allie:
            idle();
            break;
          case CaptureTheFlagFlagStatus.Carried_By_Enemy:
            captureEnemyFlag();
            break;
        }
        break;
      default:
        break;
    }

    setCharacterStateIdle();
  }

  void completeObjective() {
    objective = CaptureTheFlagPlayerAIObjective.Completed;
    setCharacterStateIdle();
  }
}