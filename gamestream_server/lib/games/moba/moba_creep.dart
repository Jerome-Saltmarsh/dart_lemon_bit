
import 'package:gamestream_server/isometric.dart';

import 'package:gamestream_server/lemon_math.dart';

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
    x = spawnOwn.x + giveOrTake(20);
    y = spawnOwn.y + giveOrTake(20);
    z = 25;
    autoTargetTimerDuration = game.fps;
    setDestinationToCurrentPosition();
  }

  bool get isTeamBlue => team == MobaGame.blueTeam;

  bool get isTeamRed => team == MobaGame.redTeam;

  IsometricGameObject get baseEnemy => isTeamBlue ? game.redBase : game.blueBase;

  IsometricGameObject get baseOwn => isTeamBlue ? game.blueBase : game.redBase;

  IsometricGameObject get spawnOwn => isTeamBlue ? game.blueSpawn : game.redSpawn;

  @override
  void customOnUpdate() {
    super.customOnUpdate();
    final target = this.target;

    if (target == null) {
      this.target = baseEnemy;
    }
  }
}