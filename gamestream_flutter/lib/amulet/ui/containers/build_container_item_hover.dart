
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:gamestream_flutter/amulet/functions/get_amulet_element_colofr.dart';
import 'package:gamestream_flutter/amulet/ui/widgets/mmo_item_image.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_components.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_widgets/lemon_widgets.dart';


Widget buildContainerAmuletItemHover({
  required Amulet amulet,
  double edgePadding = 150,
}) {

  return buildWatchNullable(
      amulet.itemHover, (item) {
        final levelCurrent = amulet.getAmuletPlayerItemLevel(item);

        if (levelCurrent == -1){
          final stats1 = item.getStatsForLevel(1);

          if (stats1 == null){
            throw Exception('stats1 == null');
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildAmuletItemIcon(item),
              height8,
              buildContainerItemStats(stats1, 1),
            ],
          );
        }

        final statsCurrent = item.getStatsForLevel(levelCurrent);

        if (statsCurrent == null){
          throw Exception('invalid amulet item level: $levelCurrent, item: $item');
        }

        final levelNext = levelCurrent + 1;
        final statsNext = item.getStatsForLevel(levelNext);

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAmuletItemIcon(item),
            height8,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildContainerItemStats(statsCurrent, levelCurrent),
                if (statsNext != null)
                 Container(
                     margin: const EdgeInsets.only(left: 32),
                     child: buildContainerItemStats(statsNext, levelNext),
                 ),
              ],
            ),
          ],
        );
      });
}


Widget buildAmuletItemIcon(AmuletItem item) => GSContainer(
  padding: const EdgeInsets.all(6),
      child: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildText(item.name.replaceAll('_', ' '),
                size: 26, color: Colors.white.withOpacity(0.8)),
            width8,
            MMOItemImage(item: item, size: 64),
          ],
        ),
      ),
    );

Widget buildContainerItemStats(AmuletItemLevel itemStats, int level) =>
    IsometricBuilder(builder: (context, components) =>
        GSContainer(
          width: 270,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GSContainer(
                padding: const EdgeInsets.all(6),
                child: buildText(itemStats.information, color: Colors.white70, align: TextAlign.center),
                color: Colors.white12,
              ),
              height4,
              buildTableRow('lvl', level),
              if (itemStats.damage != 0)
                buildTableRow('damage', itemStats.damage),
              if (itemStats.charges != 0)
                buildTableRow('charges', itemStats.charges),
              if (itemStats.cooldown != 0)
                buildTableRow('cooldown', itemStats.cooldown),
              if (itemStats.range != 0)
                buildTableRow('range', itemStats.range),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (itemStats.fire > 0)
                      buildStatColumn2(AmuletElement.fire, itemStats.fire, components),
                    if (itemStats.water > 0)
                      buildStatColumn2(AmuletElement.water, itemStats.water, components),
                    if (itemStats.electricity > 0)
                      buildStatColumn2(AmuletElement.electricity, itemStats.electricity, components),
                  ])
            ],
          ),
        ));

Widget buildStatColumn2(
    AmuletElement amuletElement,
    int amount,
    IsometricComponents components,
) =>
    buildBorder(
      color: getAmuletElementColor(amuletElement),
      radius: BorderRadius.zero,
      width: 2,
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        color: Colors.black26,
        child: buildText(amount, color: components.mmo.getAmuletElementWatch(amuletElement).value >= amount
            ? Colors.green
            : Colors.red),

      ),
    );