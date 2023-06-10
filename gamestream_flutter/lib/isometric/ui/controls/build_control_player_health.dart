import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_colors.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:golden_ratio/constants.dart';



Widget buildControlPlayerHealth() {
  final width = 200.0;
  final height = width *
      goldenRatio_0381 *
      goldenRatio_0381;


  return Tooltip(
    message: 'Health',
    child: WatchBuilder(gamestream.isometric.server.playerHealth, (int health) {

      final maxHealth = gamestream.isometric.server.playerMaxHealth;
      if (maxHealth.value <= 0) return GameStyle.Null;
      final percentage = health / maxHealth.value;
      return Container(
        width: width,
        height: height,
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              color: GameIsometricColors.redDarkest,
              width: width,
              height: height,
            ),
            Container(
              color: GameIsometricColors.red,
              width: width * percentage,
              height: height,
            ),
            Container(
              color: Colors.transparent,
              width: width,
              height: height,
              alignment: Alignment.center,
              child: text('${health.toInt()} | ${gamestream.isometric.server.playerMaxHealth}'),
            ),
          ],
        ),
      );
    }),
  );
}
