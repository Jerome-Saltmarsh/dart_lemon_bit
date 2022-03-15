

import 'package:gamestream_flutter/common/CharacterState.dart';
import 'package:gamestream_flutter/modules/isometric/animations.dart';
import 'package:gamestream_flutter/modules/isometric/atlas.dart';
import 'package:gamestream_flutter/modules/isometric/functions.dart';

void mapSrcArcher({
  required CharacterState state,
  required int direction,
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
