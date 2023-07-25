
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/ui/talent_type_src.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/ui/isometric_builder.dart';

class MMOTalentIcon extends StatelessWidget {

  final MMOTalentType talentType;
  final double size;

  const MMOTalentIcon({
    super.key,
    required this.talentType,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final src = TalentTypeSrc.map[talentType];
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