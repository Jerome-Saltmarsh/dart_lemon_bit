import 'package:gamestream_flutter/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/build_text.dart';
import 'package:gamestream_flutter/instances/engine.dart';

class ItemImage extends StatelessWidget {

  final double size;
  final int type;
  final int subType;

  const ItemImage({
    super.key,
    required this.size,
    required this.type,
    required this.subType,
  });

  @override
  Widget build(BuildContext context) {
    if (type == 0) {
      return buildText(type == 0 ? '-' :
      '${GameObjectType.getName(type)} ${GameObjectType.getNameSubType(type, subType)}'
      );
    }

    final src = Atlas.getSrc(type, subType);
    return FittedBox(
      child: Container(
        width: size,
        height: size,
        child: engine.buildAtlasImage(
          image: Atlas.getImage(type),
          srcX: src[Atlas.SrcX],
          srcY: src[Atlas.SrcY],
          srcWidth: src[Atlas.SrcWidth],
          srcHeight: src[Atlas.SrcHeight],
        ),
      ),
    );
  }

}