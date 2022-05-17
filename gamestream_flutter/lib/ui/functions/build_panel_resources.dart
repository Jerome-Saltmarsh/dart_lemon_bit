import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/icons.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/functions/styles.dart';


Widget buildPanelResources() {
  return Container(
    width: defaultPanelWidth,
    decoration: panelDecoration,
    padding: panelPadding,
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
                child: icons.resources.wood,
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
              child: icons.resources.stone,
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
              child: icons.resources.gold,
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
