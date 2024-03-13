class WeaponType {
  static const Unarmed = 0;
  static const Sword_Short = 1;
  static const Sword_Broad = 2;
  static const Sword_Long = 3;
  static const Sword_Giant = 4;
  static const Bow_Short = 5;
  static const Bow_Reflex = 6;
  static const Bow_Composite = 7;
  static const Bow_Long = 8;
  static const Staff_Wand = 9;
  static const Staff_Globe = 10;
  static const Staff_Scepter = 11;
  static const Staff_Long = 12;

  static bool isMelee(int weaponType) =>
      valuesMelee.contains(weaponType);

  static const valuesMelee = [
    ...valuesSwords,
    ...valuesStaffs,
  ];

  static const valuesBows = [
    Bow_Short,
    Bow_Reflex,
    Bow_Composite,
    Bow_Long,
  ];

  static const valuesSwords = [
    Sword_Short,
    Sword_Broad,
    Sword_Long,
    Sword_Giant,
  ];

  static const valuesStaffs = [
    Staff_Wand,
    Staff_Globe,
    Staff_Scepter,
    Staff_Long,
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
    Bow_Short: 'bow_short',
    Bow_Composite: 'bow_composite',
    Bow_Reflex: 'bow_reflex',
    Bow_Long: 'bow_long',
    Staff_Wand: 'staff_wand',
    Staff_Globe: 'staff_globe',
    Staff_Scepter: 'staff_scepter',
    Staff_Long: 'staff_long',
  };

  static String getName(int value) =>
      names[value] ?? (throw Exception('WeaponType.getName($value)'));

  static bool isBow(int weaponType) => valuesBows.contains(weaponType);

  static bool isSword(int weaponType) => valuesSwords.contains(weaponType);

  static bool isStaff(int weaponType) => valuesStaffs.contains(weaponType);
}
