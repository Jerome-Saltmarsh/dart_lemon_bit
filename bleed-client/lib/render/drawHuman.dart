import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/engine/render/drawImageRect.dart';
import 'package:bleed_client/mappers/mapCharacterToDst.dart';
import 'package:bleed_client/mappers/mapHumanToImage.dart';
import 'package:bleed_client/mappers/mapHumanToRect.dart';

void drawCharacter(Character character) {
  drawImageRect(
    mapHumanToImage(
        character.state,
        character.weapon
    ),
    mapHumanToRect(
        character.weapon,
        character.state,
        character.direction,
        character.frame),
    mapCharacterToDst(character),
  );
}

