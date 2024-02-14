class WeaponType {
  static const Unarmed = 0;
  static const Shortsword = 6;
  static const Broadsword = 25;
  static const Sword_Heavy_Sapphire = 26;
  static const Bow = 7;
  static const Staff = 15;

  static bool isMelee(int weaponType){
    return valuesMelee.contains(weaponType);
  }

  static const valuesMelee = [
    ...valuesSwords,
    ...valuesStaffs,
  ];

  static const valuesBows = [
    Bow,
  ];

  static const valuesSwords = [
    Shortsword,
    Broadsword,
    Sword_Heavy_Sapphire,
  ];

  static const valuesStaffs = [
    Staff
  ];

  static const values = [
    Unarmed,
    ...valuesNotUnarmed,
  ];

  static const valuesNotUnarmed = [
    ...valuesStaffs,
    ...valuesSwords,
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

  static bool isBow(int weaponType) => valuesBows.contains(weaponType);

  static bool isSword(int weaponType) => valuesSwords.contains(weaponType);

  static bool isStaff(int weaponType) => valuesStaffs.contains(weaponType);
}
