import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/icons.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/ui/builders/styles.dart';


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
                  child: textBuilder(player.wood)
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
                child: textBuilder(player.stone)
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
                child: textBuilder(player.gold)
            ),
          ],
        ),
      ],
    ),
  );
}
