
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';
import 'package:bleed_server/src/classes/src/player_scissors_paper_rock.dart';

class GameRockPaperScissors extends Game<PlayerScissorsPaperRock> {

  final players = <PlayerScissorsPaperRock> [];

  @override
  void update() {

  }

  @override
  Player createPlayer() {
    final instance = PlayerScissorsPaperRock(this);
    players.add(instance);

    instance.writeByte(ServerResponse.Game_Type);
    instance.writeByte(GameType.Rock_Paper_Scissors);


    return instance;
  }

  @override
  void onPlayerUpdateRequestReceived({
    required PlayerScissorsPaperRock player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool inputTypeKeyboard,
  }) {
    print("hello");
  }
}