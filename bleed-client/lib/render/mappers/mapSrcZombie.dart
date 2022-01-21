

import 'dart:typed_data';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/render/constants/atlas.dart';

import 'loop.dart';


Float32List mapSrcZombie({
  required CharacterState state,
  required Direction direction,
  required Shade shade,
  required int frame
}) {
  switch (state) {
    case CharacterState.Idle:
        return srcLoop(
            atlas: atlas.zombie.idle,
            direction: direction,
            shade: shade,
            framesPerDirection: 1,
            frame: frame
        );

    case CharacterState.Walking:
      return srcLoop(
          atlas: atlas.zombie.walking,
          direction: direction,
          shade: shade,
          framesPerDirection: 4,
          frame: frame
      );

    case CharacterState.Striking:
      return srcLoop(
          atlas: atlas.zombie.striking,
          direction: direction,
          shade: shade,
          framesPerDirection: 2,
          frame: frame
      );
  }

  throw Exception("Could not map zombie");
}