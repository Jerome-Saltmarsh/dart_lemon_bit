import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_flutter/gamestream/isometric/atlases/atlas_src_amulet_item.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/item_image.dart';
import 'package:flutter/material.dart';
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
                  isometric.amulet.aimTargetItemTypeCurrent.value = item;
                },
                onExit: (_){
                  if (isometric.amulet.aimTargetItemTypeCurrent.value != item)
                    return;
                  isometric.amulet.aimTargetItemTypeCurrent.value = null;
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

class AmuletItemImage extends StatelessWidget {
  final AmuletItem amuletItem;

  AmuletItemImage({
    required this.amuletItem,
  });

  @override
  Widget build(BuildContext context) =>
        IsometricBuilder(
          builder: (context, isometric) {
            final src = atlasSrcAmuletItem[amuletItem] ?? const [0, 0, 32, 32];
            return isometric.engine.buildAtlasImage(
              image: isometric.images.atlas_amulet_items,
              srcX: src[0],
              srcY: src[1],
              srcWidth: 32,
              srcHeight: 32,
              scale: 1.0,
            );
          }
        );
}