import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/resources.dart';
import 'package:gamestream_flutter/styles.dart';

Widget buildResourcePanel() {
  return Container(
    width: 200,
    decoration: BoxDecoration(
      color: colours.brownDark,
      borderRadius: borderRadius4,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: resources.icons.resources.wood,
              ),
              Container(
                  alignment: Alignment.center,
                  width: 48,
                  height: 48,
                  child: textBuilder(modules.game.state.player.wood)
              ),
            ],
          ),
        ),
        Column(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: resources.icons.resources.stone,
            ),
            Container(
                alignment: Alignment.center,
                width: 48,
                height: 48,
                child: textBuilder(modules.game.state.player.stone)
            ),
          ],
        ),
        Column(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: resources.icons.resources.gold,
            ),
            Container(
                alignment: Alignment.center,
                width: 48,
                height: 48,
                child: textBuilder(modules.game.state.player.gold)
            ),
          ],
        ),
      ],
    ),
  );
}
