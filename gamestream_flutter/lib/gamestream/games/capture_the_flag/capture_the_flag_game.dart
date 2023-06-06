


import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/library.dart';

class CaptureTheFlagGame extends GameIsometric {

  final scoreRed = Watch(0);
  final scoreBlue = Watch(0);

  final flagPositionRed = Vector3();
  final flagPositionBlue = Vector3();

  @override
  void drawCanvas(Canvas canvas, Size size) {
    super.drawCanvas(canvas, size);
    engine.paint.color = Colors.red;
    engine.drawLine(player.renderX, player.renderY, flagPositionRed.renderX, flagPositionBlue.renderY);
    engine.paint.color = Colors.blue;
    engine.drawLine(player.renderX, player.renderY, flagPositionBlue.renderX, flagPositionBlue.renderY);
  }

  @override
  Widget buildUI(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            bottom: 16,
            right: 16,
            child: GameIsometricUI.buildMapCircle(size: 200),
        ),
        Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: GameStyle.Container_Padding,
              color: GameStyle.Container_Color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    text("SCORE"),
                    WatchBuilder(scoreRed, (t) => text("RED: ${scoreRed.value}")),
                    WatchBuilder(scoreBlue, (t) => text("Blue: ${scoreBlue.value}")),
                ],
              ),
            ),
        ),
        Positioned(
            top: 16,
            right: 16,
            child: GameIsometricUI.buildRowMainMenu(),
        ),
      ],
    );
  }


}