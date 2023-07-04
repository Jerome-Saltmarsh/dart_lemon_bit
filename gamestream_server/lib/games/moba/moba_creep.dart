
import 'package:gamestream_server/isometric.dart';
import 'package:lemon_math/src.dart';

import 'moba_game.dart';

class MobaCreep extends IsometricZombie {

  final MobaGame game;

  MobaCreep({
    required this.game,
    required super.health,
    required super.team,
    required super.weaponDamage,
    super.x = 0,
    super.y = 0,
    super.z = 0,
  }) : super(game: game) {
    x = baseOwn.x + giveOrTake(20);
    y = baseOwn.y + giveOrTake(20);
    z = 25;
    autoTargetTimerDuration = game.fps;
    setDestinationToCurrentPosition();
  }

  bool get isTeamBlue => team == MobaGame.Team_Blue;

  bool get isTeamRed => team == MobaGame.Team_Red;

  IsometricGameObject get baseEnemy => isTeamBlue ? game.teamRedBase : game.teamBlueBase;

  IsometricGameObject get baseOwn => isTeamBlue ? game.teamBlueBase : game.teamRedBase;

  @override
  void customOnUpdate() {
    super.customOnUpdate();
    final target = this.target;

    if (target == null) {
      this.target = baseEnemy;
    }
  }
}