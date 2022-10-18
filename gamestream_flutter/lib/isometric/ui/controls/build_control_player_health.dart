import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_colors.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_watch/watch_builder.dart';



Widget buildControlPlayerHealth() {
  final width = 200.0;
  final height = width *
      goldenRatio_0381 *
      goldenRatio_0381;


  return Tooltip(
    message: 'Health',
    child: WatchBuilder(Game.player.health, (int health) {

      final maxHealth = Game.player.maxHealth;
      if (maxHealth <= 0) return empty;

      final percentage = health / maxHealth;
      return Container(
        width: width,
        height: height,
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              color: GameColors.redDarkest,
              width: width,
              height: height,
            ),
            Container(
              color: GameColors.red,
              width: width * percentage,
              height: height,
            ),
            Container(
              color: Colors.transparent,
              width: width,
              height: height,
              alignment: Alignment.center,
              child: text('${health.toInt()} | ${Game.player.maxHealth}'),
            ),
          ],
        ),
      );
    }),
  );
}
