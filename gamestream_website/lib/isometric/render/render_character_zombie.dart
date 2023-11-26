
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:lemon_engine/render.dart';

import 'render_character_health_bar.dart';
import 'src_utils.dart';

void renderCharacterZombie(Character character) {
  final shade = character.tileBelow.shade;
  if (shade < Shade.Dark) renderCharacterHealthBar(character);
  render(
      dstX: character.renderX,
      dstY: character.renderY,
      srcX: _getZombieSrcX(character),
      srcY: 789.0,
      srcWidth: 64,
      srcHeight: 64,
      anchorY: 0.66,
      scale: 0.7,
      color: character.renderColor,
  );
}

double _getZombieSrcX(Character character) {
  const framesPerDirection = 8;
  switch (character.state) {
    case CharacterState.Running:
      const frames = [3, 4, 5, 6];
      return loop4(
          animation: frames,
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