
import 'dart:typed_data';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules/isometric/animations.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';

import 'animate.dart';
import 'loop.dart';

void mapSrcKnight({
  required CharacterState state,
  required Direction direction,
  required int frame
}) {
  switch (state) {
    case CharacterState.Idle:
      return srcLoop(
          atlas: atlas.knight.idle,
          direction: direction,
          shade: Shade_Bright,
          size: 64,
          framesPerDirection: 1,
          frame: frame);
    case CharacterState.Walking:
      return srcLoop(
          atlas: atlas.knight.running,
          direction: direction,
          shade: Shade_Bright,
          size: 64,
          framesPerDirection: 4,
          frame: frame);
    case CharacterState.Striking:
      return srcAnimate(
          animation: animations.knight.striking,
          atlas: atlas.knight.striking,
          direction: direction,
          shade: Shade_Bright,
          size: 64,
          framesPerDirection: 3,
          frame: frame);
    case CharacterState.Performing:
      return srcAnimate(
          animation: animations.knight.striking,
          atlas: atlas.knight.striking,
          direction: direction,
          shade: Shade_Bright,
          size: 64,
          framesPerDirection: 3,
          frame: frame);
    case CharacterState.Running:
      return srcLoop(
          atlas: atlas.knight.running,
          direction: direction,
          shade: Shade_Bright,
          size: 64,
          framesPerDirection: 4,
          frame: frame);
    default:
      throw Exception("Could not map knight src");
  }

}
