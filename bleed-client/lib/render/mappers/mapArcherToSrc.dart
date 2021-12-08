
import 'dart:typed_data';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/render/constants/animations.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/mappers/mapCharacterSrc.dart';

Float32List _src = Float32List(4);

Float32List mapCharacterSrcArcher({
  CharacterState state,
  Direction direction,
  int frame
}) {
  switch (state) {
    case CharacterState.Dead:
      _src[0] = 1;
      _src[1] = 1;
      _src[2] = 2;
      _src[3] = 2;
      return _src;
    case CharacterState.Idle:
      return loop(
          atlas: atlas.archer.idle,
          direction: direction,
          shade: Shade.Bright,
          size: 64,
          framesPerDirection: 1,
          frame: frame);
    case CharacterState.Walking:
      return loop(
          atlas: atlas.archer.running,
          direction: direction,
          shade: Shade.Bright,
          size: 64,
          framesPerDirection: 4,
          frame: frame);
    case CharacterState.Dead:
    // TODO: Handle this case.
      break;
    case CharacterState.Aiming:
    // TODO: Handle this case.
      break;
    case CharacterState.Firing:
    // TODO: Handle this case.
      break;
    case CharacterState.Striking:
      return animate(
          animation: animations.archer.firing,
          atlas: atlas.archer.firing,
          direction: direction,
          shade: Shade.Bright,
          size: 64,
          framesPerDirection: 4,
          frame: frame);
    case CharacterState.Performing:
      return animate(
          animation: animations.witch.attacking,
          atlas: atlas.witch.striking,
          direction: direction,
          shade: Shade.Bright,
          size: 64,
          framesPerDirection: 2,
          frame: frame);
    case CharacterState.Running:
      return loop(
          atlas: atlas.archer.running,
          direction: direction,
          shade: Shade.Bright,
          size: 64,
          framesPerDirection: 4,
          frame: frame);
    case CharacterState.Reloading:
    // TODO: Handle this case.
      break;
    case CharacterState.ChangingWeapon:
    // TODO: Handle this case.
      break;
    case CharacterState.Performing:
    // TODO: Handle this case.
      break;
  }

  _src[2] = _src[0] + 64;
  _src[3] = _src[1] + 64;
  return _src;
}
