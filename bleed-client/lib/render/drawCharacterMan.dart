import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/engine/functions/onScreen.dart';
import 'package:bleed_client/engine/render/drawImageRect.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/mappers/mapCharacterToDst.dart';
import 'package:bleed_client/mappers/mapCharacterToImageMan.dart';
import 'package:bleed_client/mappers/mapHumanToRect.dart';
import 'package:bleed_client/state/isWaterAt.dart';

void drawCharacterMan(Character character) {
  if (!character.alive && isWaterAt(character.x, character.y)) return;
  if (!onScreen(character.x, character.y)) return;

  Shading shading = getShadeAtPosition(character.x, character.y);

  if (shading == Shading.VeryDark) return;

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

