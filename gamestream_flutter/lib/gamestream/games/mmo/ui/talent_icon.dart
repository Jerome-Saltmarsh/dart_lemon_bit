
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/ui/talent_type_src.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/images.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';

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
    return FittedBox(
      child: Container(
        width: size,
        height: size,
        child: src == null ? buildText('${talentType.name} src missing') :
        gamestream.engine.buildAtlasImage(
          image: Images.atlas_talents,
          srcX: src[0],
          srcY: src[1],
          srcWidth: src[2],
          srcHeight: src[3],
        ),
      ),
    );
  }
}