
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:gamestream_flutter/amulet/ui/widgets/mmo_item_image.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/packages/common/src/amulet/amulet_item.dart';
import 'package:lemon_widgets/lemon_widgets.dart';


Widget buildContainerAmuletItemHover({
  required Amulet amulet,
  double edgePadding = 150,
}) {

  return buildWatchNullable(
      amulet.itemHover, (item) {
        final level = amulet.getAmuletPlayerItemLevel(item);
        print('amulet.itemHover($item, level: $level)');

        final statsCurrent = item.getItemStatsForLevel(level);

        if (statsCurrent == null){
          throw Exception('invalid amulet item level: $level, item: $item');
        }

        final statsNext = item.getItemStatsForLevel(level + 1);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildContainerAmuletItemHoverCurrent(item, level),
            if (statsNext != null)
             Container(
                 margin: const EdgeInsets.only(left: 32),
                 child: buildContainerItemStats(statsNext),
             ),
          ],
        );
      });
}

Widget buildContainerAmuletItemHoverCurrent(AmuletItem item, int level) =>
    GSContainer(
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
                  buildTableRow('lvl', level + 1),
                  height16,
                  buildTableRow('damage', item.damage),
                  buildTableRow('cooldown', item.cooldown),
                  buildTableRow('range', item.range),
                  buildTableRow('health', item.health),
                  buildTableRow('movement', item.movement * 10),
                  if (item.attackType != null)
                    buildTableRow('attack type', item.attackType?.name),
                ],
              ));

Widget buildContainerItemStats(ItemStat itemStats) =>
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
              buildTableRow('damage', itemStats.damage),
              buildTableRow('fire', itemStats.fire),
              buildTableRow('electricity', itemStats.electricity),
              GSContainer(
                color: Colors.black12,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (itemStats.fire > 0)
                        buildStatColumn('fire', itemStats.fire),
                      if (itemStats.water > 0)
                        buildStatColumn('water', itemStats.water),
                      if (itemStats.air > 0)
                        buildStatColumn('air', itemStats.air),
                      if (itemStats.earth > 0)
                        buildStatColumn('earth', itemStats.earth),
                      if (itemStats.electricity > 0)
                        buildStatColumn('electricity', itemStats.electricity),
                    ]),
              )
            ],
          ),
        ));

Widget buildStatColumn(String name, int amount)=> Column(
    children: [
      buildText(name),
      buildText(amount) ,
    ],
  );