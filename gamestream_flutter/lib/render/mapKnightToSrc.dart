

import 'package:bleed_common/CharacterState.dart';
import 'package:bleed_common/enums/Shade.dart';
import 'package:gamestream_flutter/modules/isometric/animations.dart';
import 'package:gamestream_flutter/modules/isometric/atlas.dart';
import 'package:gamestream_flutter/modules/isometric/functions.dart';

void mapSrcKnight({
  required CharacterState state,
  required int direction,
  required int frame
}) {
  switch (state) {
    case CharacterState.Idle:
      return srcLoop(
          atlas: atlas.knight.idle,
          direction: direction,
          row: Shade.Bright,
          size: 64,
          framesPerDirection: 1,
          column: frame);
    case CharacterState.Performing:
      return srcAnimate(
          animation: animations.knight.striking,
          atlas: atlas.knight.striking,
          direction: direction,
          shade: Shade.Bright,
          size: 64,
          framesPerDirection: 3,
          frame: frame);
    case CharacterState.Running:
      return srcLoop(
          atlas: atlas.knight.running,
          direction: direction,
          row: Shade.Bright,
          size: 64,
          framesPerDirection: 4,
          column: frame);
    default:
      throw Exception("Could not map knight src");
  }

}
