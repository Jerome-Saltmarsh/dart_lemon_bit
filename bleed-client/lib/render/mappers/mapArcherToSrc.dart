

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/modules/isometric/animations.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/render/mappers/animate.dart';

import 'loop.dart';

void mapSrcArcher({
  required CharacterState state,
  required Direction direction,
  required int frame
}) {
  switch (state) {
    case CharacterState.Idle:
      return srcLoop(
          atlas: atlas.archer.idle,
          direction: direction,
          framesPerDirection: 1,
          frame: frame
      );
    case CharacterState.Walking:
      return srcLoop(
          atlas: atlas.archer.running,
          direction: direction,
          frame: frame
      );
    case CharacterState.Striking:
      return srcAnimate(
          animation: animations.archer.firing,
          atlas: atlas.archer.firing,
          direction: direction,
          frame: frame
      );
    case CharacterState.Performing:
      return srcAnimate(
          animation: animations.archer.firing,
          atlas: atlas.archer.firing,
          direction: direction,
          frame: frame
      );
    case CharacterState.Running:
      return srcLoop(
          atlas: atlas.archer.running,
          direction: direction,
          frame: frame
      );
  }

  throw Exception("Could not parse archer to src");
}
