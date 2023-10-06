
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:gamestream_flutter/amulet/amulet_ui.dart';
import 'package:gamestream_flutter/amulet/ui/widgets/mmo_item_image.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/packages/common/src/amulet/amulet_item.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';


Widget buildContainerAmuletItemHover({
  required Amulet amulet,
  double edgePadding = 150,
}) {

  final upgradeFire = Watch(0);
  final upgradeWater = Watch(0);
  final upgradeWind = Watch(0);
  final upgradeEarth = Watch(0);
  final upgradeElectricity = Watch(0);


  final upgradeFireWatch = WatchBuilder(upgradeFire, (cost) {
    if (cost <= 0) {
      return nothing;
    }
    return Column(
      children: [
        buildText('Fire'),
        buildText(cost),
      ],
    );
  });

  final upgradeCostWater = WatchBuilder(upgradeWater, (cost) {
    if (cost <= amulet.elementWater.value){
      return nothing;
    }
    return Column(
      children: [
        buildText('Water'),
        buildText(cost),
      ],
    );
  });

  final upgradeCostWind = WatchBuilder(upgradeWind, (cost) {
    if (cost <= amulet.elementWind.value){
      return nothing;
    }
    return Column(
      children: [
        buildText('Wind'),
        buildText(cost),
      ],
    );
  });

  final upgradeCostEarth = WatchBuilder(upgradeEarth, (cost) {
    if (cost <= amulet.elementEarth.value){
      return nothing;
    }
    return Column(
      children: [
        buildText('Earth'),
        buildText(cost),
      ],
    );
  });

  final upgradeCostElectricity = WatchBuilder(upgradeElectricity, (cost) {
    if (cost <= amulet.elementElectricity.value){
      return nothing;
    }
    return Column(
      children: [
        buildText('Electricity'),
        buildText(cost),
      ],
    );
  });

  final upgradeRow = Row(
    children: [
      upgradeFireWatch,
      upgradeCostWater,
      upgradeCostWind,
      upgradeCostEarth,
      upgradeCostElectricity,
    ],
  );

  return buildWatchNullable(
      amulet.itemHover, (item) {
        final level = amulet.getAmuletItemLevel(item);
        print('amulet.itemHover($item, level: $level)');

        Widget? upgradeTableRow;

        final upgradeTable = AmuletItem.upgradeTable[item];
        if (upgradeTable != null){
          if (level <= upgradeTable.length -1){
            final row = upgradeTable[level + 1];
            upgradeFire.value = row[0];
            upgradeWater.value = row[1];
            upgradeWind.value = row[2];
            upgradeEarth.value = row[3];
            upgradeElectricity.value = row[4];
          }
        }

        return GSContainer(
            width: 270,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildText(item.name.replaceAll('_', ' '), size: 26, color: Colors.white.withOpacity(0.8)),
                      width8,
                      MMOItemImage(item: item, size: 64),
                    ],
                  ),
                ),
                height16,
                AmuletUI.buildItemRow('damage', item.damage),
                AmuletUI.buildItemRow('cooldown', item.cooldown),
                AmuletUI.buildItemRow('range', item.range),
                AmuletUI.buildItemRow('health', item.health),
                AmuletUI.buildItemRow('movement', item.movement * 10),
                AmuletUI.buildItemRow('level', level + 1),
                upgradeRow,
                if (item.attackType != null)
                  AmuletUI.buildItemRow('attack type', item.attackType!.name),
                if (upgradeTableRow != null)
                  Column(
                    children: [
                      buildText('level ${level + 2}'),
                      upgradeTableRow,
                    ],
                  ),

              ],
            ));
      });
}
