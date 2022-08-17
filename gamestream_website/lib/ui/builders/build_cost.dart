import 'package:bleed_common/Cost.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/icons.dart';
import 'package:gamestream_flutter/isometric/player.dart';


Widget buildCost(Cost cost) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      if (cost.wood > 0)
        Column(
          children: [
            icons.resources.wood,
            height4,
            text(cost.wood, color: cost.wood > player.wood.value ? colours.red : colours.green),
          ],
        ),
      if (cost.stone > 0)
        Column(
          children: [
            icons.resources.stone,
            height4,
            text(cost.stone, color: cost.stone > player.stone.value ? colours.red : colours.green),
          ],
        ),
      if (cost.gold > 0)
        Column(
          children: [
            icons.resources.gold,
            height4,
            text(cost.gold, color: cost.gold > player.gold.value ? colours.red : colours.green),
          ],
        ),
    ],
  );
}