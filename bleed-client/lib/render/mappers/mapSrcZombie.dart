

import 'dart:typed_data';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/render/constants/atlas.dart';

import 'loop.dart';
import 'mapCharacterSrc.dart';


Float32List mapSrcZombie({
  CharacterState state,
  Direction direction,
  Shade shade,
  int frame
}) {
  switch (state) {
    case CharacterState.Idle:
        return loop(
            atlas: atlas.zombie.idle,
            direction: direction,
            shade: shade,
            framesPerDirection: 1,
            frame: frame
        );

    case CharacterState.Walking:
      return loop(
          atlas: atlas.zombie.walking,
          direction: direction,
          shade: shade,
          framesPerDirection: 4,
          frame: frame
      );

    case CharacterState.Striking:
      return loop(
          atlas: atlas.zombie.striking,
          direction: direction,
          shade: shade,
          framesPerDirection: 2,
          frame: frame
      );
  }

  throw Exception("Could not map zombie");
}