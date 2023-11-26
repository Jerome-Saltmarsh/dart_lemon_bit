import 'package:flutter/material.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/item_image.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:amulet_flutter/packages/common.dart';
import 'package:golden_ratio/constants.dart';

class MMOItemImage extends StatelessWidget {
  final double size;
  final AmuletItem item;
  final double scale;

  MMOItemImage({
    required this.item,
    required this.size,
    this.scale = goldenRatio_1381,
  });

  @override
  Widget build(BuildContext context) =>
        IsometricBuilder(
          builder: (context, isometric) {
            return MouseRegion(
                onEnter: (_){
                  isometric.amulet.itemHover.value = item;
                },
                onExit: (_){
                  if (isometric.amulet.itemHover.value != item)
                    return;
                  isometric.amulet.itemHover.value = null;
                },
                child: ItemImage(
                  size: size,
                  type: item.type,
                  subType: item.subType,
                  scale: scale,
                )
            );
          }
        );
}