class WeaponType {
  static const Unarmed = 0;
  static const Shortsword = 6;
  static const Broadsword = 25;
  static const Sword_Heavy_Sapphire = 26;
  static const Bow = 7;
  static const Staff = 15;

  static const valuesMelee = [
    Unarmed,
    Shortsword,
    Broadsword,
    Sword_Heavy_Sapphire,
    Staff,
  ];

  static const valuesBows = [
    Bow,
  ];

  static const values = [
    Unarmed,
    ...valuesMelee,
    ...valuesBows,
  ];

  static String getName(int value) => const {
      Unarmed: 'unarmed',
      Shortsword: 'Shortsword',
      Broadsword: 'Broadsword',
      Sword_Heavy_Sapphire: 'Sword_Heavy_Sapphire',
      Bow: 'Bow',
      Staff: 'staff',
    }[value] ?? 'weapon-type-unknown-$value';
}
