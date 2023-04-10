
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';
import 'package:bleed_server/src/classes/src/player_scissors_paper_rock.dart';

class GameRockPaperScissors extends Game<PlayerScissorsPaperRock> {

  final players = <PlayerScissorsPaperRock> [];

  GameRockPaperScissors() {

  }

  @override
  void update() {

  }

  @override
  Player createPlayer() {
    return PlayerScissorsPaperRock();
  }
}