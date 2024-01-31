import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_flutter/gamestream/isometric/atlases/atlas_src_amulet_item.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:flutter/material.dart';

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