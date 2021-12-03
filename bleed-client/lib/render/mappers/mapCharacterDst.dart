import 'dart:typed_data';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterType.dart';

import 'mapDst.dart';

const _scale = 0.66;

Float32List mapCharacterDst(
    Character character,
    CharacterType type,
    Float32List src
    ) {
  double size = src[2] - src[0];
  double scaledSize = size * _scale;
  double scaledSizeHalf = scaledSize * 0.5;
  double scaledThreeQuarters = scaledSize * 0.75;
  return mapDst(
      scale: _scale,
      x: character.x - scaledSizeHalf,
      y: character.y - scaledThreeQuarters);
}
