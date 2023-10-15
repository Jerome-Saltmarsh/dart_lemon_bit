
import 'character_sprite_group.dart';

class RenderPart {
  final CharacterSpriteGroup south;
  final CharacterSpriteGroup west;
  final CharacterSpriteGroup shadow;

  RenderPart({
    required this.south,
    required this.west,
    required this.shadow,
  });
}
