
import 'package:bleed_common/character_type.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/render/render_character_rat.dart';
import 'package:gamestream_flutter/isometric/render/render_character_slime.dart';
import 'package:gamestream_flutter/isometric/render/render_character_template.dart';
import 'package:gamestream_flutter/isometric/render/render_character_zombie.dart';
import 'package:lemon_engine/render.dart';

var renderTemplateWithWeapon = false;

void renderCharacter(Character character){
  if (!character.tile.visible) return;
  if (!character.tileBelow.visible) return;

  // renderText(text: character.direction.toString(), x: character.renderX, y: character.renderY - 100);

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
    if (character.type == CharacterType.Slime) {
      return render(
        srcX: 3040,
        srcY: (character.frame % 6) * 48.0,
        dstX: character.renderX,
        dstY: character.renderY,
        srcWidth: 48,
        srcHeight: 48,
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

  switch (character.type) {
    case CharacterType.Template:
      if (renderTemplateWithWeapon){
        renderCharacterTemplateWithWeapon(character);
      } else {
        final aimDirection = character.aimDirection;
        final weaponInFront = aimDirection >= 2 && aimDirection <= 6;
        if (!weaponInFront) {
          // renderCharacterWeapon(character);
        }
        renderCharacterTemplateWithoutWeapon(character);
        if (weaponInFront) {
          // renderCharacterWeapon(character);
        }
      }
      return;
    case CharacterType.Slime:
      return renderCharacterSlime(character);
    case CharacterType.Rat:
      return renderCharacterRat(character);
    case CharacterType.Zombie:
      return renderCharacterZombie(character);
    default:
      throw Exception("Cannot render character type: ${character.type}");
  }
}