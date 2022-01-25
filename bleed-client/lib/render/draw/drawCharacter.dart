import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/draw/drawCharacterHealthBar.dart';
import 'package:bleed_client/render/mappers/mapCharacterDst.dart';
import 'package:bleed_client/render/mappers/mapCharacterSrc.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/queries/on_screen.dart';

void drawCharacter(Character character) {
  if (!onScreen(character.x, character.y)) return;
  if (!character.alive) return;
  // if (isWaterAt(character.x, character.y)) return;

  Shade shade = getShadeAtPosition(character.x, character.y);
  if (shade.isDarkerThan(Shade.Dark)) return;

  final src = mapCharacterSrc(
    type: character.type,
    state: character.state,
    weapon: character.weapon,
    direction: character.direction,
    frame: character.frame,
    shade: shade,
  );

  drawAtlas(
    dst: mapCharacterDst(character, character.type, src),
    src: src,
  );

  if (
    character.type == CharacterType.Witch ||
    character.type == CharacterType.Swordsman ||
    character.type == CharacterType.Archer
  ) {
    if (character.team == game.player.team){
      drawCharacterMagicBar(character);
    }
  }

  drawCharacterHealthBar(character);
}
