class SpriteGroupType {
  static const Arms_Left = 1;
  static const Arms_Right = 2;
  static const Body = 3;
  static const Body_Arms = 4;
  static const Hands_Left = 5;
  static const Hands_Right = 6;
  static const Heads = 7;
  static const Helms = 8;
  static const Legs = 9;
  static const Shadow = 10;
  static const Torso = 11;
  static const Weapons = 12;

  static String getName(int value)=> const {
    Arms_Left: 'arms_left',
    Arms_Right: 'arms_right',
    Body: 'body',
    Body_Arms: 'body_arms',
    Hands_Left: 'hands_left',
    Hands_Right: 'hands_right',
    Heads: 'heads',
    Helms: 'helms',
    Legs: 'legs',
    Shadow: 'shadow',
    Torso: 'torso',
    Weapons: 'weapons',
  }[value] ?? (throw Exception('SpriteGroup.getName($value)'));

  static const values = [
    Arms_Left,
    Arms_Right,
    Body,
    Body_Arms,
    Hands_Left,
    Hands_Right,
    Heads,
    Helms,
    Legs,
    Shadow,
    Torso,
    Weapons,
  ];
}
