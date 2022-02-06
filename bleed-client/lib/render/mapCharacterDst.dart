import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';

const _size = 64;
const _anchorX = _size * 0.5;
const _anchorY = _size * 0.75;

void mapCharacterDst(
    Character character,
    CharacterType type,
    ) {
  return engine.actions.mapDst(
      scale: goldenRatio_0618,
      x: character.x,
      y: character.y,
      anchorX: _anchorX,
      anchorY: _anchorY,
  );
}
