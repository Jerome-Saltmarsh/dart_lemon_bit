import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/engine/functions/onScreen.dart';
import 'package:bleed_client/engine/render/drawImageRect.dart';
import 'package:bleed_client/mappers/mapCharacterToDst.dart';
import 'package:bleed_client/mappers/mapCharacterToImageZombie.dart';
import 'package:bleed_client/mappers/mapHumanToRect.dart';
import 'package:bleed_client/state/isWaterAt.dart';

void drawCharacterZombie(Character character) {
  if (!character.alive && isWaterAt(character.x, character.y)) return;
  if (!onScreen(character.x, character.y)) return;

  drawImageRect(
    mapCharacterToImageZombie(
        character.state,
        character.weapon
    ),
    mapCharacterToSrcZombie(
        character.weapon,
        character.state,
        character.direction,
        character.frame),
    mapCharacterToDstMan(character),
  );
}

