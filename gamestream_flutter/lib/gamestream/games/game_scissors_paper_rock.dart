
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/build_text.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/on_pressed.dart';
import 'package:gamestream_flutter/library.dart';

class GameScissorsPaperRock {
  static var totalPlayers = 0;
  static var playerTeam = 0;
  static var playerX = 0.0;
  static var playerY = 0.0;

  static final players = List.generate(100, (index) => PlayerScissorsPaperRock());
  static final colorAllie = IsometricColors.yellow;
  static final colorEnemy = IsometricColors.red;
  static final colorTarget = IsometricColors.green;

  static void init(){
    engine.zoom = 0.5;
    engine.targetZoom = 0.5;
    engine.onDrawCanvas = render;
    engine.buildUI = buildUI;
    engine.onDrawForeground = renderForeground;
  }

  static const Radius_Min = 10.0;
  static const Radius_Max = 2.5;
  static var radiusI = 0.0;
  static var radiusD = 0.03;

  static void render(Canvas canvas, Size size) {

    engine.paint.color = Colors.white;
    canvas.drawCircle(const Offset(0, 0), 300, engine.paint);

    final size = EaseFunctions.inOutQuad(radiusI) * Radius_Max + Radius_Min ;
    radiusI += radiusD;
    if (radiusI > 1) {
      radiusI = 1.0;
      radiusD = -radiusD;
    } else if (radiusI < 0) {
      radiusI = 0.0;
      radiusD = -radiusD;
    }

    for (var i = 0; i < GameScissorsPaperRock.totalPlayers; i++) {
      final player = GameScissorsPaperRock.players[i];
      engine.paint.color = getTeamColor(player.team);
      canvas.drawCircle(Offset(player.x, player.y), size, engine.paint);
      // engine.paint.color = Colors.black;
      // engine.renderText(TeamsRockPaperScissors.getName(player.team), player.x, player.y);
    }
    engine.paint.color = Colors.white;
    canvas.drawCircle(Offset(GameScissorsPaperRock.playerX, GameScissorsPaperRock.playerY), size, engine.paint);
    // engine.paint.color = colorAllie;
    // canvas.drawCircle(Offset(GameScissorsPaperRock.playerX, GameScissorsPaperRock.playerY), size * 0.5, engine.paint);
  }



  static Color getTeamColor(int team) {
     if (team == playerTeam) return colorAllie;
     switch (playerTeam) {
       case TeamsRockPaperScissors.Scissors:
         return team == TeamsRockPaperScissors.Paper ? colorTarget : colorEnemy;
       case TeamsRockPaperScissors.Paper:
         return team == TeamsRockPaperScissors.Rock ? colorTarget : colorEnemy;
       case TeamsRockPaperScissors.Rock:
         return team == TeamsRockPaperScissors.Scissors ? colorTarget : colorEnemy;
       default:
         throw Exception('GameScissorsPaperRock.getTeamColor($team)');
     }
  }

  static void renderForeground(Canvas canvas, Size size){

  }

  static Widget buildUI(BuildContext context){
    return onPressed(child: buildText('EXIT'), action: gamestream.network.disconnect);
  }
}

class PlayerScissorsPaperRock {
  var x = 0.0;
  var y = 0.0;
  var targetX = 0.0;
  var targetY = 0.0;
  var team = 0;
}
