class ItemType {
  static const Health = 0;
  static const Handgun = 1;
  static const Shotgun = 2;
  static const Orb_Ruby = 3;
  static const Orb_Topaz = 4;
  static const Orb_Emerald = 5;
  static const Sword_Wooden = 6;
  static const Sword_Steel = 7;
  static const Armour_Plated = 8;
  static const Wizards_Hat = 9;
  static const Steel_Helm = 10;

  static const orbs = [
    Orb_Emerald,
    Orb_Topaz,
    Orb_Ruby,
  ];

  static const values = [
    Health,
    Handgun,
    Shotgun,
    Orb_Ruby,
    Orb_Topaz,
    Orb_Emerald,
    Sword_Wooden,
    Sword_Steel,
    Armour_Plated,
    Wizards_Hat,
    Steel_Helm
  ];
}

extension ItemTypeExtension on ItemType {
  bool get isOrb {
    return const <int>[
      ItemType.Orb_Ruby,
      ItemType.Orb_Topaz,
      ItemType.Orb_Emerald,
    ].contains(this);
  }
}
