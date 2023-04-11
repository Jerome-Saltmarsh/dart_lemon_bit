import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';
import 'package:bleed_server/src/classes/src/player_scissors_paper_rock.dart';
import 'package:lemon_math/functions/adjacent.dart';
import 'package:lemon_math/functions/angle_between.dart';
import 'package:lemon_math/functions/opposite.dart';
import 'package:lemon_math/library.dart';

class GameRockPaperScissors extends Game<PlayerScissorsPaperRock> {

  final players = <PlayerScissorsPaperRock>[];

  @override
  void update() {
    for (final player in players) {
      const minDistance = 3.0;
      const movementSpeed = 2.0;
      final distanceX = (player.x - player.targetX).abs();
      final distanceY = (player.y - player.targetY).abs();
      if (distanceX < minDistance && distanceY < minDistance) continue;
      final angle = getAngleBetween(player.x, player.y, player.targetX, player.targetY);
      player.x -= getAdjacent(angle, movementSpeed);
      player.y -= getOpposite(angle, movementSpeed);
    }
  }

  @override
  Player createPlayer() {
    final instance = PlayerScissorsPaperRock(this);
    players.add(instance);
    instance.writeByte(ServerResponse.Game_Type);
    instance.writeByte(GameType.Rock_Paper_Scissors);
    instance.team = getNextPlayerTeam();
    instance.x = randomInt(50, 200).toDouble();
    instance.y = randomInt(50, 200).toDouble();
    instance.targetX = instance.x;
    instance.targetY = instance.y;
    return instance;
  }

  int getNextPlayerTeam(){
    final totalRocks    = countPlayersInTeam(TeamsRockPaperScissors.Rock);
    final totalPaper    = countPlayersInTeam(TeamsRockPaperScissors.Paper);
    final totalScissors = countPlayersInTeam(TeamsRockPaperScissors.Scissors);
    var nextTeam = TeamsRockPaperScissors.Rock;
    var nextTotal = totalRocks;

    if (totalPaper < nextTotal) {
      nextTeam = TeamsRockPaperScissors.Paper;
      nextTotal = totalPaper;
    }
    if (totalScissors < nextTotal) {
      nextTeam = TeamsRockPaperScissors.Scissors;
    }
    return nextTeam;
  }

  int countPlayersInTeam(int team){
     var total = 0;
     for (final player in players) {
        if (player.team != team) continue;
        total++;
     }
     return total;
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
    player.writeByte(player.team);
    player.writeInt16(player.x.toInt());
    player.writeInt16(player.y.toInt());
    player.writeUInt16(players.length);



    for (final otherPlayer in players) {
      player.writeByte(otherPlayer.team);
      player.writeInt16(otherPlayer.x.toInt());
      player.writeInt16(otherPlayer.y.toInt());
      player.writeInt16(otherPlayer.targetX.toInt());
      player.writeInt16(otherPlayer.targetY.toInt());
    }
  }
}
