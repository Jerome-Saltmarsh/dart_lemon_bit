
import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/amulet/ui/widgets/mmo_item_image.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:amulet_engine/packages/common.dart';


Widget buildContainerAmuletItemHover({
  required Amulet amulet,
}) => buildWatchNullable(
      amulet.aimTargetItemTypeCurrent, (item) {
        return amulet.amuletUI.buildContainerCompareItems(item, null);
      });


Widget buildAmuletItemIcon(AmuletItem item) {
  final dependency = item.dependency;

  final skillType = item.skillType;
  final description = item.description;

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
            if (description != null)
              Container(
                padding: const EdgeInsets.all(8),
                child: buildText(
                  description,
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
