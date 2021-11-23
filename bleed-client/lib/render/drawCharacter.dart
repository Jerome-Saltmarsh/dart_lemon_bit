import 'dart:typed_data';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/render/enums/CharacterType.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/getters/isWaterAt.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/render/mappers/mapCharacterSrc.dart';
import 'package:bleed_client/render/functions/drawRawAtlas.dart';
import 'package:bleed_client/render/mappers/mapCharacterDst.dart';
import 'package:lemon_engine/queries/on_screen.dart';

void drawCharacter(Character character, CharacterType type) {
  if (!onScreen(character.x, character.y)) return;
  if (!character.alive && isWaterAt(character.x, character.y)) return;

  Shade shade = getShadeAtPosition(character.x, character.y);
  if (shade.index >= Shade.PitchBlack.index) return;

  drawAtlas(
      mapCharacterDst(character),
      mapCharacterSrc(
        type: type,
        state: character.state,
        weapon: character.weapon,
        direction: character.direction,
        frame: character.frame,
        shade: shade,
      ));
}

void drawAtlas(Float32List dst, Float32List src) {
  drawRawAtlas(images.atlas, dst, src);
}
