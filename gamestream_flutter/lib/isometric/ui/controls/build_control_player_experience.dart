import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_colors.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_watch/watch_builder.dart';


Widget buildControlPlayerExperience() {
  final width = 200.0;
  final height = width *
      goldenRatio_0381 *
      goldenRatio_0381;

  return Tooltip(
    message: 'Experience',
    child: WatchBuilder(GameState.player.experience, (double percentage) {

      return Container(
        width: width,
        height: height,
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              color: GameColors.brownDark,
              width: width,
              height: height,
            ),
            Container(
              color: GameColors.yellow,
              width: width * percentage,
              height: height,
            ),
            Container(
              color: Colors.transparent,
              width: width,
              height: height,
              alignment: Alignment.center,
              child: WatchBuilder(GameState.player.level, (int level){
                return text('Level $level');
              }),
            ),
          ],
        ),
      );
    }),
  );
}
