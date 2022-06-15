
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:lemon_engine/engine.dart';

import 'render_character_health_bar.dart';
import 'src_utils.dart';

void renderZombie(Character character) {
  final shade = character.shade;
  if (shade > Shade.Dark) return;

  if (shade < Shade.Dark) {
    renderCharacterHealthBar(character);
  }
  _renderZombie(character, shade);
}

void _renderZombie(Character character, int shade) {
  engine.mapSrc64(
    x: mapZombieSrcX(character, shade),
    y: 789.0 + (shade * 64.0),
  );
  engine.mapDst(
      x: character.renderX,
      y: character.renderY,
      anchorX: 32,
      anchorY: 48,
      scale: 0.7);
  engine.renderAtlas();
}

double mapZombieSrcX(Character character, int shade) {
  const _framesPerDirectionZombie = 8;
  switch (character.state) {
    case CharacterState.Running:
      const frames = [3, 4, 5, 6];
      return loop4(
          animation: frames,
          character: character,
          framesPerDirection: _framesPerDirectionZombie);

    case CharacterState.Idle:
      return single(
          frame: 1,
          direction: character.direction,
          framesPerDirection: _framesPerDirectionZombie);

    case CharacterState.Hurt:
      return single(
          frame: 2,
          direction: character.direction,
          framesPerDirection: _framesPerDirectionZombie);

    case CharacterState.Performing:
      return animate(
          animation: const [7, 7, 8, 8],
          character: character,
          framesPerDirection: _framesPerDirectionZombie);
    default:
      throw Exception("Render zombie invalid state ${character.state}");
  }
}