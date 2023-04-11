
import 'package:bleed_server/src/classes/src/player.dart';
import 'package:bleed_server/src/games/game_rock_paper_scissors.dart';

class PlayerScissorsPaperRock extends Player {
  final GameRockPaperScissors game;
  var x = 0.0;
  var y = 0.0;

  var targetX = 0.0;
  var targetY = 0.0;

  var team = -1;

  PlayerScissorsPaperRock(this.game);
}