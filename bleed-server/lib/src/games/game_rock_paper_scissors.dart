import 'package:bleed_server/common/src/enums/api_spr.dart';
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';
import 'package:bleed_server/src/classes/src/player_scissors_paper_rock.dart';
import 'package:lemon_math/functions/adjacent.dart';
import 'package:lemon_math/functions/angle_between.dart';
import 'package:lemon_math/functions/opposite.dart';

class GameRockPaperScissors extends Game<PlayerScissorsPaperRock> {
  final players = <PlayerScissorsPaperRock>[];

  @override
  void update() {
    for (final player in players) {
      final angle =
          getAngleBetween(player.x, player.y, player.targetX, player.targetY);
      player.x -= getAdjacent(angle, 2);
      player.y -= getOpposite(angle, 2);
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
    if (mouseLeftDown) {
      player.targetX = player.mouse.x;
      player.targetY = player.mouse.y;
    }
  }

  @override
  void customPlayerWrite(PlayerScissorsPaperRock player) {
    player.writeByte(ServerResponse.Api_SPR);
    player.writeByte(ApiSPR.Player_Positions);
    player.writeUInt16(players.length);
    for (final otherPlayer in players) {
      player.writeInt16(otherPlayer.x.toInt());
      player.writeInt16(otherPlayer.y.toInt());
      player.writeInt16(otherPlayer.targetX.toInt());
      player.writeInt16(otherPlayer.targetY.toInt());
    }
  }
}
