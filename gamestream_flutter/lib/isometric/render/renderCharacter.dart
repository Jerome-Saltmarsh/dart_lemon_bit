
import 'package:bleed_common/character_type.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/render/render_character_rat.dart';
import 'package:gamestream_flutter/isometric/render/render_character_template.dart';
import 'package:gamestream_flutter/isometric/render/render_character_zombie.dart';
import 'package:lemon_engine/render.dart';

void renderCharacter(Character character){
  if (!character.tile.visible) return;

  if (character.spawning) {
    return render(
        srcX: 2016,
        srcY: 0,
        dstX: character.renderX,
        dstY: character.renderY,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.61
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