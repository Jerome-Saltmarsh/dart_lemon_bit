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
  Widget build(BuildContext context) {
    const size = 32.0;
    final src = atlasSrcAmuletItem[amuletItem] ?? const [0, 0, size, size];
    return AmuletImage(
      srcX: src[0],
      srcY: src[1],
      width: size,
      height: size,
      scale: scale,
    );
  }
}

class AmuletImage extends StatelessWidget {

  final double srcX;
  final double srcY;
  final double width;
  final double height;
  final double scale;

  AmuletImage({
    required this.srcX,
    required this.srcY,
    required this.width,
    required this.height,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) =>
      IsometricBuilder(
          builder: (context, isometric) =>
              isometric.engine.buildAtlasImage(
                image: isometric.images.atlas_amulet_items,
                srcX: srcX,
                srcY: srcY,
                srcWidth: width,
                srcHeight: height,
                scale: scale,
              )
      );
}