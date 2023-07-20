import 'dart:math';

import 'package:gamestream_server/common/src/rock_paper_scissors/teams_rock_paper_scissors.dart';
import 'package:gamestream_server/common/src/game_type.dart';
import 'package:gamestream_server/common/src/server_response.dart';
import 'package:gamestream_server/core/game.dart';

import 'package:gamestream_server/lemon_math.dart';

import 'rock_paper_scissors_player.dart';

class RockPaperScissorsGame extends Game<RockPaperScissorsPlayer> {

  static const movementSpeed = 4.0;

  final players = <RockPaperScissorsPlayer>[];

  RockPaperScissorsGame() : super(gameType: GameType.Rock_Paper_Scissors);

  @override
  void update() {
    for (final player in players) {
      const minDistance = 3.0;
      final distanceX = (player.x - player.targetX).abs();
      final distanceY = (player.y - player.targetY).abs();
      if (distanceX < minDistance && distanceY < minDistance) continue;
      final angle = angleBetween(player.x, player.y, player.targetX, player.targetY);
      player.x -= adj(angle, movementSpeed);
      player.y -= opp(angle, movementSpeed);
    }

    final total = players.length - 1;
    for (var i = 0; i < total; i++) {
      final playerI = players[i];
      final playerIX = playerI.x;
      final playerIY = playerI.y;

      for (var j = i + 1; j < players.length; j++){
         final playerJ = players[j];
         if (playerI.team == playerJ.team) continue;
         const radius = 50.0;
         const radiusSquared = radius * radius;
         final diffX = playerIX - playerJ.x;
         final diffY = playerIY - playerJ.y;
         if (pow(diffX, 2) + pow(diffY, 2) > radiusSquared) continue;

         if (playerI.team == TeamsRockPaperScissors.Rock) {
           respawn(playerJ.team == TeamsRockPaperScissors.Paper ? playerI : playerJ);
           continue;
         }

         if (playerI.team == TeamsRockPaperScissors.Paper) {
           respawn(playerJ.team == TeamsRockPaperScissors.Scissors ? playerI : playerJ);
           continue;
         }

         if (playerI.team == TeamsRockPaperScissors.Scissors) {
           respawn(playerJ.team == TeamsRockPaperScissors.Rock ? playerI : playerJ);
           continue;
         }
      }
    }
  }

  void respawn(RockPaperScissorsPlayer player){
    player.team = getNextPlayerTeam();
    player.x = randomInt(50, 500).toDouble();
    player.y = randomInt(50, 500).toDouble();
    player.targetX = player.x;
    player.targetY = player.y;
  }

  @override
  RockPaperScissorsPlayer createPlayer() {
    final instance = RockPaperScissorsPlayer(this);
    instance.writeByte(ServerResponse.Game_Type);
    instance.writeByte(GameType.Rock_Paper_Scissors.index);
    respawn(instance);
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
    required RockPaperScissorsPlayer player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool keyDownShift,
  }) {
    if (mouseLeftDown) {
      player.targetX = player.mouseX;
      player.targetY = player.mouseY;
    }
  }

  @override
  void removePlayer(RockPaperScissorsPlayer player) {
    players.remove(player);
  }

  @override
  int get maxPlayers => 32;
}
