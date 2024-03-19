
import 'package:amulet_client/isometric/components/types/sprite_group_type.dart';

import 'character_sprite_group.dart';

class HumanCharacterSprites {
  final armor = <int, CharacterSpriteGroup>{};
  final head = <int, CharacterSpriteGroup>{};
  final helm = <int, CharacterSpriteGroup>{};
  final torso = <int, CharacterSpriteGroup>{};
  final weapons = <int, CharacterSpriteGroup>{};
  final shadow = <int, CharacterSpriteGroup>{};
  final hair = <int, CharacterSpriteGroup>{};
  final shoes = <int, CharacterSpriteGroup>{};

  late final values = {
    SpriteGroupType.Armor: armor,
    SpriteGroupType.Head: head,
    SpriteGroupType.Helm: helm,
    SpriteGroupType.Torso: torso,
    SpriteGroupType.Weapon: weapons,
    SpriteGroupType.Shadow: shadow,
    SpriteGroupType.Hair: hair,
    SpriteGroupType.Shoes: shoes,
  };
}
