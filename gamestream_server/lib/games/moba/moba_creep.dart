
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
  }) {
    x = spawnOwn.x + giveOrTake(20);
    y = spawnOwn.y + giveOrTake(20);
    z = 25;
    autoTargetTimerDuration = game.fps;
    setDestinationToCurrentPosition();
  }

  bool get isTeamBlue => team == MobaGame.blueTeam;

  bool get isTeamRed => team == MobaGame.redTeam;

  GameObject get baseEnemy => isTeamBlue ? game.redBase : game.blueBase;

  GameObject get baseOwn => isTeamBlue ? game.blueBase : game.redBase;

  GameObject get spawnOwn => isTeamBlue ? game.blueSpawn : game.redSpawn;

  @override
  void update() {
    super.update();
    final target = this.target;
    if (target == null) {
      this.target = baseEnemy;
    }
  }
}