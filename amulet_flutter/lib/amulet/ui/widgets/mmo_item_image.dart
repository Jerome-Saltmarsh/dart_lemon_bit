import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_flutter/gamestream/isometric/atlases/atlas_src_amulet_item.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/item_image.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

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

class WatchAmuletItem extends StatelessWidget {
  final Watch<AmuletItem?> watch;

  WatchAmuletItem(this.watch);

  @override
  Widget build(BuildContext context) {
    const size = 50.0;
    return Container(
      alignment: Alignment.center,
      color: Colors.white12,
      padding: const EdgeInsets.all(2),
      child: Container(
          alignment: Alignment.center,
          color: Colors.black12,
          padding: const EdgeInsets.all(2),
          child: WatchBuilder(watch,
                  (t) => t == null ? nothing : AmuletItemImage(amuletItem: t, scale: size / 32,)
          ),
        ),
    );
  }
}

class AmuletItemImage extends StatelessWidget {
  final double scale;
  final AmuletItem amuletItem;

  AmuletItemImage({
    required this.amuletItem,
    required this.scale,
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
              scale: scale,
            );
          }
        );
}