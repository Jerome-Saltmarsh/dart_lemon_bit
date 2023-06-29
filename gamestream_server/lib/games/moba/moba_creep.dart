
import 'package:gamestream_server/isometric.dart';
import 'package:lemon_math/src.dart';

import 'moba_game.dart';

class MobaCreep extends IsometricZombie {

  late final MobaGame game;

  late IsometricGameObject baseEnemy;
  late IsometricGameObject baseOwn;

  MobaCreep({
    required super.game,
    required super.health,
    required super.team,
    required super.damage,
    super.x = 0,
    super.y = 0,
    super.z = 0,
  }) {
    this.game = game;
    baseEnemy = team == MobaGame.teamBlue ? game.teamRedBase : game.teamBlueBase;
    baseOwn = team == MobaGame.teamBlue ? game.teamBlueBase : game.teamRedBase;
    x = baseOwn.x + giveOrTake(20);
    y = baseOwn.y + giveOrTake(20);
    z = 25;
    setDestinationToCurrentPosition();
  }

  @override
  void customOnUpdate() {
    final target = this.target;

    if (target == null) {
      this.target = baseEnemy;
    }
  }
}