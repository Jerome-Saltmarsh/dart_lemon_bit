import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/mappers/mapCharacterToDst.dart';
import 'package:bleed_client/mappers/mapCharacterToImageMan.dart';
import 'package:bleed_client/mappers/mapHumanToRect.dart';
import 'package:bleed_client/getters/isWaterAt.dart';
import 'package:lemon_engine/queries/on_screen.dart';
import 'package:lemon_engine/render/draw_image_rect.dart';

void drawCharacterMan(Character character) {
  if (!onScreen(character.x, character.y)) return;
  if (!character.alive && isWaterAt(character.x, character.y)) return;

  Shade shading = getShadeAtPosition(character.x, character.y);
  if (shading.index >= Shade.PitchBlack.index) return;

  drawImageRect(
    mapCharacterToImageMan(
        character.state,
        character.weapon,
        shading
    ),
    mapCharacterToSrcMan(
        character.weapon,
        character.state,
        character.direction,
        character.frame),
    mapCharacterToDstMan(character),
  );
}

