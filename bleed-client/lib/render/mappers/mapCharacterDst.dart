import 'dart:typed_data';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:lemon_engine/engine.dart';

const _scale = 0.66;

void mapCharacterDst(
    Character character,
    CharacterType type,
    ) {
  double size = engine.state.src[2] - engine.state.src[0];
  double scaledSize = size * _scale;
  double scaledSizeHalf = scaledSize * 0.5;
  double scaledThreeQuarters = scaledSize * 0.75;
  return engine.actions.mapDst(
      scale: _scale,
      x: character.x - scaledSizeHalf,
      y: character.y - scaledThreeQuarters);
}
