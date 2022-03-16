
import 'package:bleed_common/CharacterState.dart';
import 'package:bleed_common/enums/Shade.dart';
import 'package:gamestream_flutter/modules/isometric/animations.dart';
import 'package:gamestream_flutter/modules/isometric/atlas.dart';
import 'package:gamestream_flutter/modules/isometric/functions.dart';

void mapSrcWitch({
  required CharacterState state,
  required int direction,
  required int frame
}) {
  switch (state) {
    case CharacterState.Idle:
      return srcLoop(
          atlas: atlas.witch.idle,
          direction: direction,
          shade: Shade.Bright,
          size: 64,
          framesPerDirection: 1,
          frame: frame);
    case CharacterState.Dead:
    // TODO: Handle this case.
      break;
    case CharacterState.Performing:
      return srcAnimate(
          animation: animations.witch.attacking,
          atlas: atlas.witch.striking,
          direction: direction,
          shade: Shade.Bright,
          size: 64,
          framesPerDirection: 2,
          frame: frame);
    case CharacterState.Running:
      return srcLoop(
          atlas: atlas.witch.running,
          direction: direction,
          shade: Shade.Bright,
          size: 64,
          framesPerDirection: 4,
          frame: frame);
    case CharacterState.Changing:
    // TODO: Handle this case.
      break;
  }

  throw Exception("could not map src witch");
}
