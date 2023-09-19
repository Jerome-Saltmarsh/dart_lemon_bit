
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/amulet/ui/consts/atlasSrcTalentType.dart';

import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class MMOTalentIcon extends StatelessWidget {

  final AmuletTalentType talentType;
  final double size;

  const MMOTalentIcon({
    super.key,
    required this.talentType,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final src = atlasSrcTalentType[talentType];
    return Container(
      width: size,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: IsometricBuilder(
          builder: (context, isometric) {
            return Container(
              child: src == null ? buildText('${talentType.name} src missing') :
              isometric.engine.buildAtlasImage(
                image: isometric.images.atlas_talents,
                srcX: src[0],
                srcY: src[1],
                srcWidth: src[2],
                srcHeight: src[3],
              ),
            );
          }
        ),
      ),
    );
  }
}