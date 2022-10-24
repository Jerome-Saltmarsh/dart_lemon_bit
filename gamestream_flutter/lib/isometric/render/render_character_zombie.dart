

import 'package:bleed_common/library.dart';

import '../../library.dart';
import 'render_character_health_bar.dart';
import 'src_utils.dart';

void renderCharacterZombie(Character character) {
  final shade = GameState.getV3RenderShade(character);
  if (shade < Shade.Dark) renderCharacterHealthBar(character);
  if (character.deadOrDying) return;
  if (character.spawning) return;

  GameRender.renderCharacterCustomShadow(
      character: character,
      frame: character.frame,
      direction: character.renderDirection,
      image: GameImages.zombie_shadow,
  );

  Engine.renderSprite(
      image: GameImages.zombie,
      srcX: getZombieSrcX(character),
      srcY: character.renderDirection * 64,
      srcWidth: 64,
      srcHeight: 64,
      dstX: character.renderX,
      dstY: character.renderY,
      anchorY: 0.66,
      scale: 0.7,
      color: character.color,
  );
}

double getZombieSrcX(Character character) {
  const framesPerDirection = 0;
  switch (character.state) {
    case CharacterState.Running:
      return loop4(
          animation: const [3, 4, 5, 6],
          character: character,
          framesPerDirection: framesPerDirection
      );
    case CharacterState.Idle:
      return single(
          frame: 1,
          direction: character.direction,
          framesPerDirection: framesPerDirection
      );
    case CharacterState.Hurt:
      return single(
          frame: 2,
          direction: character.direction,
          framesPerDirection: framesPerDirection,
      );
    case CharacterState.Dying:
      return single(
        frame: 2,
        direction: character.direction,
        framesPerDirection: framesPerDirection,
      );
    case CharacterState.Performing:
      return animate(
          animation: const [7, 7, 8, 8],
          character: character,
          framesPerDirection: framesPerDirection,
      );
    default:
      throw Exception("Render zombie invalid state ${character.state}");
  }
}

