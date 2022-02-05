import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:lemon_engine/engine.dart';

const _scale = 0.66;
const size = 64;
const scaledSize = size * _scale;
const scaledSizeHalf = scaledSize * 0.5;
const scaledThreeQuarters = scaledSize * 0.75;

void mapCharacterDst(
    Character character,
    CharacterType type,
    ) {
  return engine.actions.mapDst(
      scale: _scale,
      x: character.x - scaledSizeHalf,
      y: character.y - scaledThreeQuarters);
}
