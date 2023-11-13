
import 'package:gamestream_flutter/gamestream/isometric/components/types/sprite_group_type.dart';

import 'character_sprite_group.dart';

class KidCharacterSprites {
  final armLeft = <int, CharacterSpriteGroup>{};
  final armRight  = <int, CharacterSpriteGroup>{};
  final bodyMale = <int, CharacterSpriteGroup>{};
  final bodyFemale = <int, CharacterSpriteGroup>{};
  final bodyArms = <int, CharacterSpriteGroup>{};
  final handLeft = <int, CharacterSpriteGroup>{};
  final handRight = <int, CharacterSpriteGroup>{};
  final head = <int, CharacterSpriteGroup>{};
  final helm = <int, CharacterSpriteGroup>{};
  final legs = <int, CharacterSpriteGroup>{};
  final torsoTop = <int, CharacterSpriteGroup>{};
  final torsoBottom = <int, CharacterSpriteGroup>{};
  final weapons = <int, CharacterSpriteGroup>{};
  final shadow = <int, CharacterSpriteGroup>{};
  final hair = <int, CharacterSpriteGroup>{};
  final shoesLeft = <int, CharacterSpriteGroup>{};
  final shoesRight = <int, CharacterSpriteGroup>{};

  late final values = {
    SpriteGroupType.Arms_Left: armLeft,
    SpriteGroupType.Arms_Right: armRight,
    SpriteGroupType.Body_Male: bodyMale,
    SpriteGroupType.Body_Female: bodyFemale,
    SpriteGroupType.Body_Arms: bodyArms,
    SpriteGroupType.Hands_Left: handLeft,
    SpriteGroupType.Hands_Right: handRight,
    SpriteGroupType.Heads: head,
    SpriteGroupType.Helms: helm,
    SpriteGroupType.Legs: legs,
    SpriteGroupType.Torso_Top: torsoTop,
    SpriteGroupType.Torso_Bottom: torsoBottom,
    SpriteGroupType.Weapons: weapons,
    SpriteGroupType.Shadow: shadow,
    SpriteGroupType.Hair: hair,
    SpriteGroupType.Shoes_Left: shoesLeft,
    SpriteGroupType.Shoes_Right: shoesRight,

  };
}
