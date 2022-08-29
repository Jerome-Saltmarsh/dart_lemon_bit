
import 'package:bleed_common/character_type.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/render/render_character_rat.dart';
import 'package:gamestream_flutter/isometric/render/render_character_template.dart';
import 'package:gamestream_flutter/isometric/render/render_character_zombie.dart';
import 'package:lemon_engine/render.dart';

void renderCharacter(Character character){
  if (!character.tile.visible) return;

  if (character.spawning) {

    if (character.type == CharacterType.Rat){
      return render(
        srcX: 1920,
        srcY: (character.frame % 8) * 43.0,
        dstX: character.renderX,
        dstY: character.renderY,
        srcWidth: 64,
        srcHeight: 43,
        scale: 0.75,
      );
    }

    return render(
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

  switch(character.type){
    case CharacterType.Template:
      return renderCharacterTemplate(character);
    case CharacterType.Rat:
      return renderCharacterRat(character);
    case CharacterType.Zombie:
      return renderCharacterZombie(character);
    default:
      throw Exception("Cannot render character type: ${character.type}");
  }
}