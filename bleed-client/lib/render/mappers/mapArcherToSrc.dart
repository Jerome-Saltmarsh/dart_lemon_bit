
import 'dart:typed_data';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/render/constants/animations.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/mappers/animate.dart';

import 'loop.dart';

final Float32List _src = Float32List(4);

Float32List mapSrcArcher({
  required CharacterState state,
  required Direction direction,
  required int frame
}) {
  switch (state) {
    case CharacterState.Dead:
      _src[0] = 1;
      _src[1] = 1;
      _src[2] = 2;
      _src[3] = 2;
      return _src;
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
      return animate(
          animation: animations.archer.firing,
          atlas: atlas.archer.firing,
          direction: direction,
          frame: frame
      );
    case CharacterState.Performing:
      return animate(
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

  _src[2] = _src[0] + 64;
  _src[3] = _src[1] + 64;
  return _src;
}
