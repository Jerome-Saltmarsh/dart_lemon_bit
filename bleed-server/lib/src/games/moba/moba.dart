
import 'package:bleed_server/common/src/game_type.dart';
import 'package:bleed_server/src/isometric/isometric_game.dart';

import 'moba_player.dart';

class Moba extends IsometricGame<MobaPlayer> {

  Moba({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Moba);


  @override
  int get maxPlayers => 10;

  @override
  MobaPlayer buildPlayer() {
    final player = MobaPlayer(game: this);
    player.x = 100;
    player.y = 100;
    player.z = 50;
    return player;
  }

}