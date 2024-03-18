
import 'character_sprite_group.dart';

class CharacterShader {
  final CharacterSpriteGroup flat;
  final CharacterSpriteGroup west;
  final CharacterSpriteGroup south;
  final CharacterSpriteGroup shadow;

  CharacterShader({
    required this.flat,
    required this.west,
    required this.south,
    required this.shadow,
  });
}