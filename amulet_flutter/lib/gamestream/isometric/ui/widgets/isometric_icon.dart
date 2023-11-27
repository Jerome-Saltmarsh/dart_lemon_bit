
import 'package:flutter/cupertino.dart';
import 'package:amulet_flutter/gamestream/isometric/atlases/atlas_src_icon_type.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';

class IsometricIcon extends StatelessWidget {

  final IconType iconType;
  final double scale;
  final int? color;

  const IsometricIcon({super.key,
    required this.iconType,
    this.scale = 1.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) =>
      IsometricBuilder(
        builder: (context, isometric) {
          final src = atlasSrcIconType[iconType] ?? (throw Exception('atlasSrcIconType[$iconType] is null'));
          return FittedBox(
            child: isometric.engine.buildAtlasImage(
              image: isometric.images.atlas_icons,
              srcX: src[0],
              srcY: src[1],
              srcWidth: src[2],
              srcHeight: src[3],
              scale: scale,
              color: color,
            ),
          );
        }
      );
}