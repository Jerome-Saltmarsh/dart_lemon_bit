
import 'package:amulet_flutter/gamestream/isometric/components/types/sprite_group_type.dart';

import 'character_sprite_group.dart';

class KidCharacterSprites {
  final bodyMale = <int, CharacterSpriteGroup>{};
  final bodyFemale = <int, CharacterSpriteGroup>{};
  final handLeft = <int, CharacterSpriteGroup>{};
  final handRight = <int, CharacterSpriteGroup>{};
  final head = <int, CharacterSpriteGroup>{};
  final helm = <int, CharacterSpriteGroup>{};
  final legs = <int, CharacterSpriteGroup>{};
  final torso = <int, CharacterSpriteGroup>{};
  final weapons = <int, CharacterSpriteGroup>{};
  final weaponsTrail = <int, CharacterSpriteGroup>{};
  final shadow = <int, CharacterSpriteGroup>{};
  final hair = <int, CharacterSpriteGroup>{};
  final shoes = <int, CharacterSpriteGroup>{};

  late final values = {
    SpriteGroupType.Body_Male: bodyMale,
    SpriteGroupType.Body_Female: bodyFemale,
    SpriteGroupType.Hand_Left: handLeft,
    SpriteGroupType.Hand_Right: handRight,
    SpriteGroupType.Head: head,
    SpriteGroupType.Helm: helm,
    SpriteGroupType.Legs: legs,
    SpriteGroupType.Torso: torso,
    SpriteGroupType.Weapon: weapons,
    SpriteGroupType.Weapon_Trail: weaponsTrail,
    SpriteGroupType.Shadow: shadow,
    SpriteGroupType.Hair: hair,
    SpriteGroupType.Shoes: shoes,
  };
}
