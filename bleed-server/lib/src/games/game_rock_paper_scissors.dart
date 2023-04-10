
import 'package:bleed_server/common/src/enums/api_spr.dart';
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';
import 'package:bleed_server/src/classes/src/player_scissors_paper_rock.dart';

class GameRockPaperScissors extends Game<PlayerScissorsPaperRock> {

  final players = <PlayerScissorsPaperRock> [];

  @override
  void update() {
    for (final player in players){
      player.x += 0.1;
    }
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

  }

  @override
  void customPlayerWrite(PlayerScissorsPaperRock player) {
      player.writeByte(ServerResponse.Api_SPR);
      player.writeByte(ApiSPR.Player_Positions);
      player.writeUInt16(players.length);
      for (final player in players) {
          player.writeInt16(player.x.toInt());
          player.writeInt16(player.y.toInt());
      }
  }
}