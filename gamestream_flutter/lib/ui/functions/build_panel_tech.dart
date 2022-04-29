import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/styles.dart';

import 'build_tech_type_row.dart';
import 'player.dart';

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
        buildTechTypeRow(TechType.Pickaxe, player.levelPickaxe),
        buildTechTypeRow(TechType.Sword, player.levelSword),
        buildTechTypeRow(TechType.Bow, player.levelBow),
      ],
    ),
  );
}
