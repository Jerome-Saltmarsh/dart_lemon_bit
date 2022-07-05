import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_watch/watch_builder.dart';


Widget buildControlPlayerExperience() {
  final width = 200.0;
  final height = width *
      goldenRatio_0381 *
      goldenRatio_0381;

  return Tooltip(
    message: 'Experience',
    child: WatchBuilder(player.experience, (double percentage) {

      return Container(
        width: width,
        height: height,
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              color: colours.brownLight,
              width: width,
              height: height,
            ),
            Container(
              color: colours.yellow,
              width: width * percentage,
              height: height,
            ),
            Container(
              color: Colors.transparent,
              width: width,
              height: height,
              alignment: Alignment.center,
              child: WatchBuilder(player.level, (int level){
                return text('Level $level');
              }),
            ),
          ],
        ),
      );
    }),
  );
}
