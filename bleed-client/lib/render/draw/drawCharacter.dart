import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/draw/drawCharacterHealthBar.dart';
import 'package:bleed_client/render/mappers/mapCharacterDst.dart';
import 'package:bleed_client/render/mappers/mapCharacterSrc.dart';
import 'package:lemon_engine/engine.dart';

void drawCharacter(Character character) {
  if (!onScreen(character.x, character.y)) return;
  if (!character.alive) return;

  final shade = isometric.properties.getShadeAtPosition(character.x, character.y);
  if (shade > (Shade_Dark)) return;

  mapCharacterSrc(
    type: character.type,
    state: character.state,
    weapon: character.weapon,
    direction: character.direction,
    frame: character.frame,
    shade: shade,
  );

  mapCharacterDst(character, character.type);
  engine.actions.renderAtlas();

  if (
    character.type == CharacterType.Witch ||
    character.type == CharacterType.Swordsman ||
    character.type == CharacterType.Archer
  ) {
    if (character.team == modules.game.state.player.team){
      drawCharacterMagicBar(character);
    }
  }

  drawCharacterHealthBar(character);
}
