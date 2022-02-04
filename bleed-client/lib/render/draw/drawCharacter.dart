import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/SlotType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/draw/drawCharacterHealthBar.dart';
import 'package:bleed_client/render/mappers/loop.dart';
import 'package:bleed_client/render/mappers/mapCharacterDst.dart';
import 'package:bleed_client/render/mappers/mapCharacterSrc.dart';
import 'package:lemon_engine/engine.dart';

void drawCharacter(Character character) {
  if (!onScreen(character.x, character.y)) return;
  if (!character.alive) return;

  final shade = isometric.properties.getShadeAtPosition(character.x, character.y);
  if (shade > (Shade_Dark)) return;

  if (character.direction.index > Direction.Right.index){
    _renderCharacterWeapon(character);
    _renderCharacter(character, shade);
  } else {
    _renderCharacter(character, shade);
    _renderCharacterWeapon(character);
  }




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

void _renderCharacter(Character character, int shade) {
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
}

void _renderCharacterWeapon(Character character) {
  
  if (character.equippedSlotType == SlotType.Empty) return;

  if (character.equippedSlotType == SlotType.Sword_Wooden){
    srcSingle(atlas: atlas.weapons.swordWooden.idle, direction: character.direction);
    mapCharacterDst(character, character.type);
    engine.actions.renderAtlas();
  }
  if (character.equippedSlotType == SlotType.Sword_Short){
    srcSingle(atlas: atlas.weapons.swordSteel.idle, direction: character.direction);
    mapCharacterDst(character, character.type);
    engine.actions.renderAtlas();
  }
}
