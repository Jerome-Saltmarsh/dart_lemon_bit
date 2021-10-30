import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/engine/render/drawImageRect.dart';
import 'package:bleed_client/mappers/mapCharacterToDst.dart';
import 'package:bleed_client/mappers/mapCharacterToImageMan.dart';
import 'package:bleed_client/mappers/mapHumanToRect.dart';

void drawCharacterMan(Character character) {
  drawImageRect(
    mapCharacterToImageMan(
        character.state,
        character.weapon
    ),
    mapCharacterToSrcMan(
        character.weapon,
        character.state,
        character.direction,
        character.frame),
    mapCharacterToDstMan(character),
  );
}

