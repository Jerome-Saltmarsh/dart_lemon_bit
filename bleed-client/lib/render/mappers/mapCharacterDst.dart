import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';

const _scale = goldenRatio_0618;
const _size = 64;
const _scaledSize = _size * _scale;
const _scaledSizeHalf = _scaledSize * 0.5;
const _scaledThreeQuarters = _scaledSize * 0.75;

void mapCharacterDst(
    Character character,
    CharacterType type,
    ) {
  return engine.actions.mapDst(
      scale: _scale,
      x: character.x - _scaledSizeHalf,
      y: character.y - _scaledThreeQuarters);
}
