
import 'package:bleed_server/src/classes/src/isometric_player.dart';
import 'package:bleed_server/src/games/game_isometric.dart';

class GameCastleStorm extends GameIsometric {
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