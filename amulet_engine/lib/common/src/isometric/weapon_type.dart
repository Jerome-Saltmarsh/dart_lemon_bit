class WeaponType {
  static const Unarmed = 0;
  static const Sword_Short = 1;
  static const Sword_Broad = 2;
  static const Sword_Long = 3;
  static const Sword_Claymore = 4;
  static const Bow = 4;
  static const Staff = 5;

  static bool isMelee(int weaponType) =>
      valuesMelee.contains(weaponType);

  static const valuesMelee = [
    ...valuesSwords,
    ...valuesStaffs,
  ];

  static const valuesBows = [
    Bow,
  ];

  static const valuesSwords = [
    Sword_Short,
    Sword_Broad,
    Sword_Long,
    Sword_Claymore,
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
      Sword_Short: 'sword_short',
      Sword_Broad: 'sword_broad',
      Sword_Long: 'sword_long',
      Bow: 'Bow',
      Staff: 'staff',
    }[value] ?? 'weapon-type-unknown-$value';

  static bool isBow(int weaponType) => valuesBows.contains(weaponType);

  static bool isSword(int weaponType) => valuesSwords.contains(weaponType);

  static bool isStaff(int weaponType) => valuesStaffs.contains(weaponType);
}
