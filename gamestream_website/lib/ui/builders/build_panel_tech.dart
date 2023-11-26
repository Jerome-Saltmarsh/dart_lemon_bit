import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/styles.dart';

import 'build_row_tech_type.dart';

Widget buildPanelTech() {
  return Container(
    width: 200,
    padding: padding8,
    decoration: BoxDecoration(
      color: colours.brownDark,
      borderRadius: borderRadius4,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildRowTechType(TechType.Pickaxe, player.levelPickaxe),
        buildRowTechType(TechType.Sword, player.levelSword),
        buildRowTechType(TechType.Bow, player.levelBow),
        buildRowTechType(TechType.Axe, player.levelAxe),
        buildRowTechType(TechType.Hammer, player.levelHammer),
        buildRowTechType(TechType.Bag, player.levelBag),
      ],
    ),
  );
}
