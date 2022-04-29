import 'package:bleed_common/Cost.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/resources.dart';


Widget buildCost(Cost cost) {
  final player = modules.game.state.player;
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      if (cost.wood > 0)
        Column(
          children: [
            resources.icons.resources.wood,
            height4,
            text(cost.wood, color: cost.wood > player.wood.value ? colours.red : colours.green),
          ],
        ),
      if (cost.stone > 0)
        Column(
          children: [
            resources.icons.resources.stone,
            height4,
            text(cost.stone, color: cost.stone > player.stone.value ? colours.red : colours.green),
          ],
        ),
      if (cost.gold > 0)
        Column(
          children: [
            resources.icons.resources.gold,
            height4,
            text(cost.gold, color: cost.gold > player.gold.value ? colours.red : colours.green),
          ],
        ),
    ],
  );
}