
import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/amulet/ui/widgets/amulet_element_icon.dart';
import 'package:amulet_flutter/amulet/ui/widgets/mmo_item_image.dart';
import 'package:amulet_flutter/gamestream/isometric/isometric_components.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:amulet_engine/packages/common.dart';


Widget buildContainerAmuletItemHover({
  required Amulet amulet,
  double edgePadding = 150,
}) => buildWatchNullable(
      amulet.itemHover, (item) {
        return buildAmuletItemIcon(item);
      });


Widget buildAmuletItemIcon(AmuletItem item) {
  final dependency = item.dependency;

  final skillType = item.skillType;

  return GSContainer(
    width: 278,
      child: FittedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GSContainer(
              color: Colors.black12,
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildText(item.name.replaceAll('_', ' ').toUpperCase(),
                      size: 26, color: Colors.white.withOpacity(0.8)),
                  width8,
                  MMOItemImage(item: item, size: 64),
                ],
              ),
            ),
            height8,
            if (item.description.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                child: buildText(
                  item.description,
                  color: Colors.white70,
                  align: TextAlign.center,
                ),
              ),
            if (dependency != null)
              GSContainer(
                  padding: const EdgeInsets.all(6),
                  color: Colors.black12,
                  child: buildText(
                    'requires ${WeaponType.getName(dependency)}',
                    color: Colors.white54,
                    italic: true,
                  ),
              ),
            if (skillType != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    buildText('Skill'),
                    buildText(skillType.name),
                  ],
                ),
              )
          ],
        ),
      ),
    );
}

// Widget buildContainerAmuletItemStats(
//     AmuletItemStats amuletItemStats,
//     int level,
//     {Color? color}
// ) =>
//     IsometricBuilder(builder: (context, components) =>
//         buildBorder(
//           color: color ?? Colors.transparent,
//           width: 2,
//           child: GSContainer(
//             width: 276,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Row(
//                   children: [
//                     GSContainer(
//                       height: 32,
//                       color: color ?? Colors.white,
//                       child: buildText('LVL $level'), padding: const EdgeInsets.all(4),
//                     ),
//                     const Expanded(child: SizedBox()),
//                     Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           if (amuletItemStats.fire > 0)
//                             buildStatColumn2(AmuletElement.fire, amuletItemStats.fire, components),
//                           if (amuletItemStats.water > 0)
//                             buildStatColumn2(AmuletElement.water, amuletItemStats.water, components),
//                           if (amuletItemStats.electricity > 0)
//                             buildStatColumn2(AmuletElement.air, amuletItemStats.electricity, components),
//                         ])
//
//                   ],
//                 ),
//                 if (amuletItemStats.information != null)
//                   GSContainer(
//                     padding: const EdgeInsets.all(6),
//                     child: buildText(amuletItemStats.information, color: Colors.white70, align: TextAlign.center),
//                     color: Colors.white12,
//                   ),
//                 height4,
//                 if (amuletItemStats.damageMin != 0)
//                   buildTableRow('damage', '${amuletItemStats.damageMin} - ${amuletItemStats.damageMax}'),
//                 if (amuletItemStats.charges != 0)
//                   buildTableRow('charges', amuletItemStats.charges),
//                 if (amuletItemStats.cooldown != 0)
//                   buildTableRow('cooldown', amuletItemStats.cooldown),
//                 if (amuletItemStats.range != 0)
//                   buildTableRow('range', amuletItemStats.range),
//                 if (amuletItemStats.quantity != 0)
//                   buildTableRow('quantity', amuletItemStats.quantity),
//                 if (amuletItemStats.health != 0)
//                   buildTableRow('health', amuletItemStats.health),
//               ],
//             ),
//           ),
//         ));

Widget buildStatColumn2(
    AmuletElement amuletElement,
    int amount,
    IsometricComponents components,
) =>
    Row(
      children: [
        AmuletElementIcon(amuletElement: amuletElement),
        Container(
          alignment: Alignment.center,
          width: 32,
          height: 32,
          color: Colors.black12,
          child: FittedBox(
            child: buildText(amount, color: components.amulet.getAmuletElementWatch(amuletElement).value >= amount
                ? Colors.green
                : Colors.red
            ),
          ),
        ),
      ],
    );