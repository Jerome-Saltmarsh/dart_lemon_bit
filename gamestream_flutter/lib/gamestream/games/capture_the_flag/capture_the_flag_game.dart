


import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:bleed_common/src/capture_the_flag/src.dart';

class CaptureTheFlagGame extends GameIsometric {

  final scoreRed = Watch(0);
  final scoreBlue = Watch(0);

  final flagPositionRed = Vector3();
  final flagPositionBlue = Vector3();

  final flagStatusRed = Watch(CaptureTheFlagFlagStatus.At_Base);
  final flagStatusBlue = Watch(CaptureTheFlagFlagStatus.At_Base);

  @override
  void drawCanvas(Canvas canvas, Size size) {
    super.drawCanvas(canvas, size);
    engine.paint.color = Colors.red;
    engine.drawLine(player.renderX, player.renderY, flagPositionRed.renderX, flagPositionRed.renderY);
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
                    WatchBuilder(scoreRed, (score) => text("RED: $score")),
                    WatchBuilder(scoreBlue, (score) => text("BlUE: $score")),
                ],
              ),
            ),
        ),
        Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: GameStyle.Container_Padding,
              color: GameStyle.Container_Color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text("FLAG STATUS"),
                  WatchBuilder(flagStatusRed, (status) => text("RED STATUS: ${CaptureTheFlagFlagStatus.getName(status)}")),
                  WatchBuilder(flagStatusBlue, (status) => text("BLUE STATUS: ${CaptureTheFlagFlagStatus.getName(status)}")),
                ],
              ),
            )),
        Positioned(
            top: 16,
            right: 16,
            child: GameIsometricUI.buildRowMainMenu(),
        ),
      ],
    );
  }


}