

import 'dart:typed_data';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/render/constants/atlas.dart';

import 'mapCharacterSrc.dart';

final Float32List _src = Float32List(4);

final double _size = 64;

Float32List mapSrcZombie({
  CharacterState state,
  Direction direction,
  Shade shade,
  int frame
}) {
  switch (state) {
    case CharacterState.Idle:
        _src[0] = atlas.zombie.idle.x + (direction.index * _size);
        _src[1] = atlas.zombie.idle.y + (shade.index * _size);
        break;

    case CharacterState.Walking:
      return loop(
          atlas: atlas.zombie.walking,
          direction: direction,
          shade: shade,
          size: _size,
          framesPerDirection: 4,
          frame: frame);
      break;

    case CharacterState.Striking:
      double _s = direction.index * _size * 2;
      double _f = (frame % 4) * _size;
      _src[0] = _s + _f + atlas.zombie.striking.x;
      _src[1] = shade.index * _size + atlas.zombie.striking.y;
      break;
  }

  _src[2] = _src[0] + _size;
  _src[3] = _src[1] + _size;
  return _src;
}