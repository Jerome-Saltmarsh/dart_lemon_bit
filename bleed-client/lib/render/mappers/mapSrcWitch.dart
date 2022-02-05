
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules/isometric/animations.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';

import 'animate.dart';
import 'loop.dart';

void mapSrcWitch({
  required CharacterState state,
  required Direction direction,
  required int frame
}) {

  switch (state) {
    case CharacterState.Idle:
      return srcLoop(
          atlas: atlas.witch.idle,
          direction: direction,
          shade: Shade_Bright,
          size: 64,
          framesPerDirection: 1,
          frame: frame);
    case CharacterState.Dead:
    // TODO: Handle this case.
      break;
    case CharacterState.Firing:
    // TODO: Handle this case.
      break;
    case CharacterState.Striking:
      return srcAnimate(
          animation: animations.witch.attacking,
          atlas: atlas.witch.striking,
          direction: direction,
          shade: Shade_Bright,
          size: 64,
          framesPerDirection: 2,
          frame: frame);
    case CharacterState.Performing:
      return srcAnimate(
          animation: animations.witch.attacking,
          atlas: atlas.witch.striking,
          direction: direction,
          shade: Shade_Bright,
          size: 64,
          framesPerDirection: 2,
          frame: frame);
    case CharacterState.Running:
      return srcLoop(
          atlas: atlas.witch.running,
          direction: direction,
          shade: Shade_Bright,
          size: 64,
          framesPerDirection: 4,
          frame: frame);
    case CharacterState.ChangingWeapon:
    // TODO: Handle this case.
      break;
  }

  throw Exception("could not map src witch");
}
