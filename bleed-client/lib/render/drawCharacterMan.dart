import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/getters/isWaterAt.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/mappers/mapCharacterToImageMan.dart';
import 'package:bleed_client/mappers/mapCharacterToSrc.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';
import 'package:bleed_client/render/functions/drawRawAtlas.dart';
import 'package:lemon_engine/queries/on_screen.dart';

Float32List _dst = Float32List(4);
Float32List _src = Float32List(4);

const double _manSize = 64.0;
const double _manSizeHalf = _manSize * 0.5;

void drawCharacter(Character character, CharacterType type) {
  if (!onScreen(character.x, character.y)) return;
  if (!character.alive && isWaterAt(character.x, character.y)) return;

  Shade shade = getShadeAtPosition(character.x, character.y);
  if (shade.index >= Shade.PitchBlack.index) return;

  mapCharacterToDst(character, _dst);

  mapCharacterToSrc(
      type: type,
      state: character.state,
      weapon: character.weapon,
      direction: character.direction,
      frame: character.frame,
      shade: shade,
      src: _src);

  drawAtlas(_dst, _src);
}

void drawAtlas(Float32List dst, Float32List src){
  drawRawAtlas(images.atlas, dst, src);
}


void mapCharacterToDst(Character character, Float32List rsTransform){
  rsTransform[0] = 0.75; // scale
  rsTransform[1] = 0; // rotation
  rsTransform[2] = character.x - _manSizeHalf; // x
  rsTransform[3] = character.y - _manSizeHalf; // y
}

