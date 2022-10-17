
import 'package:bleed_common/character_type.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/grid_state_util.dart';
import 'package:gamestream_flutter/isometric/render/render_character_rat.dart';
import 'package:gamestream_flutter/isometric/render/render_character_slime.dart';
import 'package:gamestream_flutter/isometric/render/render_character_zombie.dart';
import 'package:lemon_engine/engine.dart';

import 'render_character_template.dart';

var renderTemplateWithWeapon = false;

void renderCharacter(Character character){
  if (!isVisibleV3(character)) return;

  if (character.spawning) {
    if (character.characterType == CharacterType.Rat){
      return Engine.renderBuffer(
        srcX: 1920,
        srcY: (character.frame % 8) * 43.0,
        dstX: character.renderX,
        dstY: character.renderY,
        srcWidth: 64,
        srcHeight: 43,
        scale: 0.75,
      );
    }
    if (character.characterType == CharacterType.Slime) {
      return Engine.renderBuffer(
        srcX: 3040,
        srcY: (character.frame % 6) * 48.0,
        dstX: character.renderX,
        dstY: character.renderY,
        srcWidth: 48,
        srcHeight: 48,
        scale: 0.75,
      );
    }
    return Engine.renderBuffer(
        srcX: 2016,
        srcY: (character.frame % 8) * 73.0,
        dstX: character.renderX,
        dstY: character.renderY,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.61,
        scale: 0.75,
    );
  }

  switch (character.characterType) {
    case CharacterType.Template:
      renderCharacterTemplate(character);
      // renderCharacterZombie(character);
      return;
    case CharacterType.Slime:
      return renderCharacterSlime(character);
    case CharacterType.Rat:
      return renderCharacterRat(character);
    case CharacterType.Zombie:
      return renderCharacterZombie(character);
    default:
      throw Exception("Cannot render character type: ${character.characterType}");
  }
}