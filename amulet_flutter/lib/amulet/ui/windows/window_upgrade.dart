
import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/amulet/amulet_ui.dart';
import 'package:amulet_flutter/amulet/classes/amulet_colors.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class WindowUpgrade extends StatelessWidget {

  final Amulet amulet;

  AmuletUI get amuletUI => amulet.amuletUI;

  const WindowUpgrade({super.key, required this.amulet});

  @override
  Widget build(BuildContext context) =>
      buildWatch(amulet.equippedChangedNotifier, (t) => buildWindow());

  Widget buildWindow() => GSContainer(
      child: Column(
        children: [
          buildText('UPGRADES'),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: amulet.equippableSlotTypes
                .map(buildSlotType)
                .toList(growable: false),
          )
        ],
      ),
    );

  Widget buildSlotType(SlotType slotType) =>
      buildAmuletItemObject(amulet.getEquipped(slotType));

  Widget buildAmuletItemObject(AmuletItemObject? amuletItemObject) {
    if (amuletItemObject == null){
      return nothing;
    }

    return Column(
        children: [
          // buildText('lvl 3'),
          // height8,
          onPressed(
            action: () => amulet.upgradeSlotType(amuletItemObject.amuletItem.slotType),
            child: amuletUI.tryBuildCardAmuletItemObject(amuletItemObject) ,
          ),
          buildText('100g', color: AmuletColors.Gold),
        ],
      );
  }

}