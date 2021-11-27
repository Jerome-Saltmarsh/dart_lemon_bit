
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/getters/isWaterAt.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/enums/CharacterType.dart';
import 'package:bleed_client/render/mappers/mapCharacterDst.dart';
import 'package:bleed_client/render/mappers/mapCharacterSrc.dart';
import 'package:lemon_engine/queries/on_screen.dart';

void drawCharacter(Character character, CharacterType type) {
  if (!onScreen(character.x, character.y)) return;
  if (!character.alive && isWaterAt(character.x, character.y)) return;

  Shade shade = getShadeAtPosition(character.x, character.y);
  if (shade.index >= Shade.PitchBlack.index) return;

  drawAtlas(
      mapCharacterDst(character, type),
      mapCharacterSrc(
        type: type,
        state: character.state,
        weapon: character.weapon,
        direction: character.direction,
        frame: character.frame,
        shade: shade,
      ));
}

