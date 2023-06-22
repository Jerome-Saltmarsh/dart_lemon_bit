
import 'package:bleed_server/common/src/rock_paper_scissors/api_spr.dart';
import 'package:bleed_server/common/src/server_response.dart';
import 'package:bleed_server/src/game/player.dart';

import 'rock_paper_scissors_game.dart';

class RockPaperScissorsPlayer extends Player {
  final RockPaperScissorsGame game;
  var x = 0.0;
  var y = 0.0;

  var targetX = 0.0;
  var targetY = 0.0;

  var team = -1;

  RockPaperScissorsPlayer(this.game);

  @override
  void writePlayerGame() {
    writeByte(ServerResponse.Api_SPR);
    writeByte(ApiSPR.Player_Positions);
    writeByte(team);
    writeInt16(x.toInt());
    writeInt16(y.toInt());
    writeUInt16(game.players.length);

    for (final otherPlayer in game.players) {
      writeByte(otherPlayer.team);
      writeInt16(otherPlayer.x.toInt());
      writeInt16(otherPlayer.y.toInt());
      writeInt16(otherPlayer.targetX.toInt());
      writeInt16(otherPlayer.targetY.toInt());
    }
  }
}