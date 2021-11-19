import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/getters/isWaterAt.dart';
import 'package:bleed_client/mappers/mapCharacterToImageMan.dart';
import 'package:bleed_client/mappers/mapCharacterToSrc.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';
import 'package:bleed_client/render/functions/drawDebugBox.dart';
import 'package:bleed_client/render/functions/drawRawAtlas.dart';
import 'package:lemon_engine/queries/on_screen.dart';

Float32List _transform = Float32List(4);
Float32List _src = Float32List(4);

const double _manSize = 64.0;
const double _manSizeHalf = _manSize * 0.5;

void drawCharacterMan(Character character) {
  if (!onScreen(character.x, character.y)) return;
  if (!character.alive && isWaterAt(character.x, character.y)) return;

  Shade shade = getShadeAtPosition(character.x, character.y);
  if (shade.index >= Shade.PitchBlack.index) return;

  Image image = mapCharacterToImage(
      type: CharacterType.Human,
      state: character.state,
      weapon: character.weapon,
  );

  if (image == null){
    throw Exception("could not map image for man ${character.state} ${character.weapon}");
  }

  mapCharacterToRSTransform(character, _transform);

  mapCharacterToSrc(
      type: CharacterType.Human,
      state: character.state,
      weapon: character.weapon,
      direction: character.direction,
      frame: character.frame,
      shade: shade,
      src: _src);

  drawRawAtlas(image, _transform, _src);
}

void mapCharacterToRSTransform(Character character, Float32List rsTransform){
  rsTransform[0] = 1;
  rsTransform[1] = 0;
  rsTransform[2] = character.x - _manSizeHalf;
  rsTransform[3] = character.y - _manSizeHalf;
}

