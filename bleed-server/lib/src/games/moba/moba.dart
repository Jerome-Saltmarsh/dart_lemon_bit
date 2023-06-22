
import 'package:bleed_server/common/src/game_type.dart';
import 'package:bleed_server/src/games/moba/moba_player.dart';
import 'package:bleed_server/src/isometric/isometric_game.dart';

class Moba extends IsometricGame<MobaPlayer> {

  Moba({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Moba);


  @override
  int get maxPlayers => 10;

  @override
  MobaPlayer buildPlayer() => MobaPlayer(game: this);

}