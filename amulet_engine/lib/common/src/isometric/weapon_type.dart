class WeaponType {
  static const Unarmed = 0;
  static const Sword_Short = 1;
  static const Sword_Broad = 2;
  static const Sword_Long = 3;
  static const Sword_Giant = 4;
  static const Bow = 5;
  static const Staff = 6;

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
    Sword_Giant,
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

  static const names = {
    Unarmed: 'unarmed',
    Sword_Short: 'sword_short',
    Sword_Broad: 'sword_broad',
    Sword_Long: 'sword_long',
    Sword_Giant: 'sword_giant',
    Bow: 'Bow',
    Staff: 'staff',
  };

  static String getName(int value) =>
      names[value] ?? (throw Exception('WeaponType.getName($value)'));

  static bool isBow(int weaponType) => valuesBows.contains(weaponType);

  static bool isSword(int weaponType) => valuesSwords.contains(weaponType);

  static bool isStaff(int weaponType) => valuesStaffs.contains(weaponType);
}
