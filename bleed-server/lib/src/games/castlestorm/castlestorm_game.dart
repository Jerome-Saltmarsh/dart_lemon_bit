

import 'package:bleed_server/common/src/game_type.dart';
import 'package:bleed_server/src/games/castlestorm/castlestorm_player.dart';
import 'package:bleed_server/src/games/isometric/isometric_game.dart';

/// The objective of castle storm is to capture all of the points on the map
class CastleStormGame extends IsometricGame<CastleStormPlayer> {
  CastleStormGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.CastleStorm);

  @override
  CastleStormPlayer buildPlayer() => CastleStormPlayer(game: this);

  @override
  void customUpdate() {

  }

  @override
  int get maxPlayers => 16;
}