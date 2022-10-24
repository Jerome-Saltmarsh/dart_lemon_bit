
import 'package:bleed_common/character_type.dart';
import 'package:gamestream_flutter/isometric/render/render_character_rat.dart';
import 'package:gamestream_flutter/isometric/render/render_character_slime.dart';
import 'package:gamestream_flutter/isometric/render/render_character_zombie.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_engine/engine.dart';

import 'render_character_template.dart';

void renderCharacter(Character character){
  if (!GameQueries.isVisibleV3(character)) return;

  if (character.spawning) {
    if (character.characterType == CharacterType.Rat){
      Engine.renderSprite(
        image: GameImages.gameobjects,
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
      Engine.renderSprite(
        image: GameImages.gameobjects,
        srcX: 3040,
        srcY: (character.frame % 6) * 48.0,
        dstX: character.renderX,
        dstY: character.renderY,
        srcWidth: 48,
        srcHeight: 48,
        scale: 0.75,
      );
      return;
    }
    Engine.renderSprite(
      image: GameImages.gameobjects,
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