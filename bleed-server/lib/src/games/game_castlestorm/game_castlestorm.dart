
import 'package:bleed_server/src/games/game_isometric/isometric_game.dart';
import 'package:bleed_server/src/games/game_isometric/isometric_player.dart';

class GameCastleStorm extends IsometricGame {
  GameCastleStorm({
    required super.scene,
    required super.time,
    required super.environment,
    required super.gameType,
  });

  @override
  IsometricPlayer buildPlayer() {
    // TODO: implement buildPlayer
    throw UnimplementedError();
  }

}