import 'package:flutter/material.dart';
import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class ItemImage extends StatelessWidget {

  final double size;
  final int type;
  final int subType;
  final double scale;

  const ItemImage({
    super.key,
    required this.size,
    required this.type,
    required this.subType,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (type == 0) {
      return buildText(type == 0 ? '-' :
      '${ItemType.getName(type)} ${ItemType.getNameSubType(type, subType)}'
      );
    }

    final src = Atlas.getSrc(type, subType);
    return FittedBox(
      child: IsometricBuilder(
        builder: (context, isometric) {
          return Container(
            width: size,
            height: size,
            color: Colors.transparent,
            child: isometric.engine.buildAtlasImage(
              image: isometric.rendererGameObjects.getImageForGameObjectType(type),
              srcX: src[Atlas.SrcX],
              srcY: src[Atlas.SrcY],
              srcWidth: src[Atlas.SrcWidth],
              srcHeight: src[Atlas.SrcHeight],
              scale: scale,
            ),
          );
        }
      ),
    );
  }

}