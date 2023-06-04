
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:bleed_server/src/games/isometric/isometric_player.dart';

class CaptureTheFlagPlayer extends IsometricPlayer {

  @override
  final CaptureTheFlagGame game;

  CaptureTheFlagPlayer({required this.game}) : super(game: game);

  @override
  void writePlayerGame() {
    super.writePlayerGame();
  }
}