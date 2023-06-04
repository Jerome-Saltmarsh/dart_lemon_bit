
import 'package:bleed_server/src/games/isometric/isometric_player.dart';

import 'castlestorm_game.dart';

class CastleStormPlayer extends IsometricPlayer {

  @override
  final CastleStormGame game;

  CastleStormPlayer({required this.game}) : super(game: game);

}