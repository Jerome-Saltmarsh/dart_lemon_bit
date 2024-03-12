
import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/amulet/amulet_ui.dart';
import 'package:amulet_flutter/amulet/classes/amulet_colors.dart';
import 'package:amulet_flutter/isometric/builders/build_watch.dart';
import 'package:amulet_flutter/isometric/consts/height.dart';
import 'package:amulet_flutter/isometric/consts/width.dart';
import 'package:amulet_flutter/isometric/ui/widgets/gs_container.dart';
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText('UPGRADES'),
              width16,
              amuletUI.buildButtonClose(amulet.windowVisibleUpgrade),
            ],
          ),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
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

    final amuletItem = amuletItemObject.amuletItem;
    final level = amuletItemObject.level;

    final controlCost = buildText('${amuletItem.getUpgradeCost(level)}g', color: AmuletColors.Gold);
    final controlCard = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: onPressed(
        action: () => amulet.upgradeSlotType(amuletItemObject.amuletItem.slotType),
        child: amuletUI.tryBuildCardAmuletItemObject(amuletItemObject) ,
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
        children: [
          controlCost,
          controlCard,
        ],
      );
  }

}