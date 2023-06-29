
import 'package:gamestream_server/isometric.dart';
import 'package:lemon_math/src.dart';

import 'moba_game.dart';

class MobaCreep extends IsometricCharacter {

  final MobaGame game;

  late IsometricGameObject baseEnemy;
  late IsometricGameObject baseOwn;

  MobaCreep({
    required this.game,
    required super.characterType,
    required super.health,
    required super.weaponType,
    required super.team,
    required super.damage,
    required super.weaponRange,
  }) {
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