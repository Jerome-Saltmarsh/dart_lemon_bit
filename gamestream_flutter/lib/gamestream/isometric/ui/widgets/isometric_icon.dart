
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_icons.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/images.dart';
import 'package:gamestream_flutter/ui/isometric_builder.dart';

class IsometricIcon extends StatelessWidget {

  final IconType iconType;
  final double scale;
  final int color;

  const IsometricIcon({super.key,
    required this.iconType,
    this.scale = 1.0,
    this.color = 1,
  });

  @override
  Widget build(BuildContext context) =>
      IsometricBuilder(
        builder: (context, isometric) => FittedBox(
            child: isometric.engine.buildAtlasImage(
              image: isometric.images.atlas_icons,
              srcX: AtlasIcons.getSrcX(iconType),
              srcY: AtlasIcons.getSrcY(iconType),
              srcWidth: AtlasIcons.getSrcWidth(iconType),
              srcHeight: AtlasIcons.getSrcHeight(iconType),
              scale: scale,
              color: color,
            ),
          )
      );
}