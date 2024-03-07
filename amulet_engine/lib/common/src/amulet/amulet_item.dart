import '../../src.dart';
import 'package:collection/collection.dart';

enum AmuletItem {
  Weapon_Sword_Short(
    label: 'Short Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Short,
    attackSpeed: AttackSpeed.Very_Fast,
    range: WeaponRange.Very_Short,
    damageMin: 0.5,
    damage: 4,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Assassins_Blade(
    label: 'Assassins Blade',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Short,
    attackSpeed: AttackSpeed.Very_Fast,
    range: WeaponRange.Very_Short,
    damageMin: 0.8,
    damage: 5,
    skillSet: {
      SkillType.Critical_Hit: 5,
      SkillType.Agility: 5,
    },
    quality: ItemQuality.Unique,
  ),
  Unique_Weapon_Swift_Blade(
    label: 'Swift Blade',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Short,
    attackSpeed: AttackSpeed.Very_Fast,
    range: WeaponRange.Very_Short,
    damageMin: 0.65,
    damage: 6,
    skillSet: {
      SkillType.Critical_Hit: 5,
      SkillType.Agility: 5,
    },
    quality: ItemQuality.Rare,
  ),
  Weapon_Sword_Broad(
    label: 'Broad Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Broad,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Short,
    damageMin: 0.8,
    damage: 8,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Sword_Long(
    label: 'Long Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Long,
    attackSpeed: AttackSpeed.Slow,
    range: WeaponRange.Long,
    damageMin: 0.8,
    damage: 12,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Sword_Giant(
    label: 'Giant Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Giant,
    attackSpeed: AttackSpeed.Very_Slow,
    range: WeaponRange.Very_Long,
    damageMin: 0.7,
    damage: 20,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Bow_Short(
    label: 'Short Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Short,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Very_Short,
    damageMin: 0.9,
    damage: 4,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Bow_Reflex(
    label: 'Reflex Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Reflex,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Short,
    damageMin: 0.5,
    damage: 6,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Bow_Composite(
    label: 'Composite Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Composite,
    attackSpeed: AttackSpeed.Slow,
    range: WeaponRange.Long,
    damageMin: 0.5,
    damage: 8,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Bow_Long(
    label: 'Long Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Long,
    attackSpeed: AttackSpeed.Very_Slow,
    range: WeaponRange.Very_Long,
    damageMin: 0.75,
    damage: 12,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Staff_Wand(
    label: 'Wand',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Wand,
    attackSpeed: AttackSpeed.Very_Fast,
    range: WeaponRange.Very_Short,
    damageMin: 0.85,
    damage: 3,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Staff_Globe(
    label: 'Globe',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Globe,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Short,
    damageMin: 0.5,
    damage: 6,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Staff_Scepter(
      label: 'Scepter',
      slotType: SlotType.Weapon,
      subType: WeaponType.Staff_Scepter,
      attackSpeed: AttackSpeed.Slow,
      range: WeaponRange.Long,
      damageMin: 0.6,
      damage: 5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
      ),
  Weapon_Staff_Long(
      label: 'Staff',
      slotType: SlotType.Weapon,
      subType: WeaponType.Staff_Long,
      attackSpeed: AttackSpeed.Very_Slow,
      range: WeaponRange.Very_Long,
      damageMin: 0.8,
      damage: 8,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Helm_Leather_Cap(
    label: 'Leather Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Leather_Cap,
    maxHealth: 5,
    maxMagic: 3,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Helm_Steel_Cap(
    label: 'Steel Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Steel_Cap,
    maxHealth: 8,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Helm_Full(
    label: 'Full Helm',
    slotType: SlotType.Helm,
    subType: HelmType.Full_Helm,
    maxHealth: 11,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Helm_Crooked_Hat(
    label: 'Crooked Hat',
    slotType: SlotType.Helm,
    subType: HelmType.Pointed_Hat_Purple,
    maxHealth: 1,
    maxMagic: 10,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Helm_Pointed_Hat(
    label: 'Pointed Hat',
    slotType: SlotType.Helm,
    subType: HelmType.Pointed_Hat_Black,
    maxHealth: 2,
    maxMagic: 15,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Helm_Cowl(
    label: 'Cowl',
    slotType: SlotType.Helm,
    subType: HelmType.Cowl,
    maxHealth: 2,
    maxMagic: 7,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Helm_Feathered_Cap(
    label: 'Feather Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Feather_Cap,
    maxHealth: 3,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Helm_Cape(
    label: 'Cape',
    slotType: SlotType.Helm,
    subType: HelmType.Cape,
    maxHealth: 4,
    maxMagic: 2,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Helm_Veil(
    label: 'Veil',
    slotType: SlotType.Helm,
    subType: HelmType.Cape,
    maxHealth: 4,
    maxMagic: 2,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Armor_Tunic(
    label: 'Tunic',
    slotType: SlotType.Armor,
    subType: ArmorType.Tunic,
    maxHealth: 5,
    maxMagic: 5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Armor_Leather(
    label: 'Leather',
    slotType: SlotType.Armor,
    subType: ArmorType.Leather,
    maxHealth: 10,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Armor_Chainmail(
    label: 'Chainmail',
    slotType: SlotType.Armor,
    subType: ArmorType.Chainmail,
    maxHealth: 20,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Armor_Platemail(
    label: 'Platemail',
    slotType: SlotType.Armor,
    subType: ArmorType.Platemail,
    maxHealth: 30,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Armor_Robes(
    label: 'Robes',
    slotType: SlotType.Armor,
    subType: ArmorType.Robes,
    maxHealth: 5,
    maxMagic: 10,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Armor_Cloak(
    label: 'Cloak',
    slotType: SlotType.Armor,
    subType: ArmorType.Cloak,
    maxHealth: 10,
    maxMagic: 5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Armor_Mantle(
    label: 'Mantle',
    slotType: SlotType.Armor,
    subType: ArmorType.Mantle,
    maxHealth: 6,
    maxMagic: 6,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Armor_Shroud(
    label: 'Shroud',
    slotType: SlotType.Armor,
    subType: ArmorType.Shroud,
    maxHealth: 9,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Shoes_Leather_Boots(
    label: 'Leather Boots',
    slotType: SlotType.Shoes,
    subType: ShoeType.Leather_Boots,
    maxHealth: 5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Shoes_Grieves(
    label: 'Grieves',
    slotType: SlotType.Shoes,
    subType: ShoeType.Grieves,
    maxHealth: 5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Shoes_Warrior_3_Sabatons_Common(
    label: 'Sabatons',
    slotType: SlotType.Shoes,
    subType: ShoeType.Sabatons,
    maxHealth: 5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Shoes_Black_Slippers(
    label: 'Black Slippers',
    slotType: SlotType.Shoes,
    subType: ShoeType.Black_Slippers,
    maxHealth: 1,
    maxMagic: 5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Shoes_Footwraps(
    label: 'Footwraps',
    slotType: SlotType.Shoes,
    subType: ShoeType.Footwraps,
    maxHealth: 1,
    maxMagic: 5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Shoes_Soles(
    label: 'Soles',
    slotType: SlotType.Shoes,
    subType: ShoeType.Soles,
    maxHealth: 1,
    maxMagic: 5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Shoes_Treads(
    label: 'Treads',
    slotType: SlotType.Shoes,
    subType: ShoeType.Treads,
    maxHealth: 1,
    maxMagic: 5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Shoes_Striders(
    label: 'Striders',
    slotType: SlotType.Shoes,
    subType: ShoeType.Striders,
    maxHealth: 1,
    maxMagic: 5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Shoes_Satin_Boots(
    label: 'Satin_Boots',
    slotType: SlotType.Shoes,
    subType: ShoeType.Satin_Boots,
    maxHealth: 1,
    maxMagic: 5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Consumable_Potion_Magic(
    label: 'Magic Potion',
    slotType: SlotType.Consumable,
    subType: ConsumableType.Potion_Blue,
    skillSet: {
    },
  ),
  Consumable_Potion_Health(
      label: 'Health Potion',
      slotType: SlotType.Consumable,
      subType: ConsumableType.Potion_Red,
    skillSet: {
    },
  );

  // int get levelMax => level + 1;

  /// the minimum level of a fiend that can drop this item
  // final int level;

  /// the maximum level of fiends that can drop this item

  /// see item_type.dart in commons
  final SlotType slotType;
  final int subType;
  final double? damageMin;
  /// per level
  final double? damage;
  final WeaponRange? range;
  final AttackSpeed? attackSpeed;
  final ItemQuality quality;
  final String label;
  final int? maxHealth;
  final int? maxMagic;
  // final List<SkillType> skillTypes;
  final Map<SkillType, double> skillSet;

  const AmuletItem({
    required this.slotType,
    required this.subType,
    required this.label,
    this.quality = ItemQuality.Common,
    this.skillSet = const {},
    this.maxHealth = 0,
    this.maxMagic,
    this.range,
    this.attackSpeed,
    this.damageMin,
    this.damage,
  });

  bool get isWeapon => slotType == SlotType.Weapon;

  bool get isWeaponSword => isWeapon && WeaponType.isSword(subType);

  bool get isWeaponStaff => isWeapon && WeaponType.isStaff(subType);

  bool get isWeaponBow => isWeapon && WeaponType.isBow(subType);

  bool get isShoes => slotType == SlotType.Shoes;

  bool get isHelm => slotType == SlotType.Helm;

  bool get isConsumable => slotType == SlotType.Consumable;

  bool get isArmor => slotType == SlotType.Armor;

  int get quantify {
    var total = 0.0;
    total += maxHealth ?? 0;
    total += maxMagic ?? 0;
    total += range?.quantify ?? 0;
    return total.toInt();
  }

  static AmuletItem? findByName(String name) =>
      values.firstWhereOrNull((element) => element.name == name);

  static final Consumables =
      values.where((element) => element.isConsumable).toList(growable: false);

  static final sortedValues = () {
    final vals = List.of(values);
    vals.sort(sortByQuantify);
    return vals;
  }();

  static int sortByQuantify(AmuletItem a, AmuletItem b) {
    final aQuantify = a.quantify;
    final bQuantify = b.quantify;
    if (aQuantify < bQuantify) {
      return -1;
    }
    if (aQuantify > bQuantify) {
      return 1;
    }
    return 0;
  }

  void validate() {
    if (isWeapon) {
      if ((attackSpeed == null)) {
        throw Exception('$this performDuration of weapon cannot be null');
      }
      if (range == null) {
        throw Exception('$this.range cannot cannot be null');
      }
    }
  }

  int getSkillPoints(int level) {
    const pointsPerLevel = 3;
    final bonus = getItemQualityBonus(quality);
    return (level * pointsPerLevel * bonus).toInt();
  }

  static double getItemQualityBonus(ItemQuality itemQuality){
    switch (itemQuality){
      case ItemQuality.Common:
        return 1.0;
      case ItemQuality.Unique:
        return 1.3;
      case ItemQuality.Rare:
        return 1.61;
    }
  }

  static const itemValues = const {
    ItemQuality.Common: {
      1: 5,
      2: 10,
      3: 16,
      4: 20,
    },
    ItemQuality.Unique: {
      1: 7,
      2: 13,
      3: 18,
      4: 26,
    },
    ItemQuality.Rare: {
      1: 12,
      2: 20,
      3: 25,
      4: 35,
    },
  };
}

enum CasteType {
  Bow,
  Sword,
  Staff,
  Caste,
  Melee,
  Passive,
}



enum WeaponClass {
  Sword,
  Staff,
  Bow;

  static WeaponClass fromWeaponType(int weaponType) {
    if (WeaponType.isBow(weaponType)) {
      return WeaponClass.Bow;
    }
    if (WeaponType.isSword(weaponType)) {
      return WeaponClass.Sword;
    }
    if (WeaponType.isStaff(weaponType)) {
      return WeaponClass.Staff;
    }
    throw Exception(
        'amuletPlayer.getWeaponTypeWeaponClass(weaponType: $weaponType)');
  }
}

enum WeaponRange {
  Very_Short(melee: 50, ranged: 150),
  Short(melee: 70, ranged: 175),
  Long(melee: 90, ranged: 200),
  Very_Long(melee: 110, ranged: 225);

  final double melee;
  final double ranged;

  const WeaponRange({required this.melee, required this.ranged});

  int get quantify => (index * 4).toInt();
}

enum AreaDamage {
  Very_Small(value: 0.25),
  Small(value: 0.50),
  Large(value: 0.75),
  Very_Large(value: 1.0);

  final double value;

  const AreaDamage({required this.value});

  static AreaDamage from(double value) {
    for (final areaDamage in values) {
      if (areaDamage.value > value) continue;
      return areaDamage;
    }
    return values.last;
  }

  int get quantify {
    return (this.value * 6).toInt();
  }
}

enum AttackSpeed {
  Very_Slow(duration: 48),
  Slow(duration: 40),
  Fast(duration: 32),
  Very_Fast(duration: 24);

  final int duration;

  const AttackSpeed({required this.duration});

  static AttackSpeed fromDuration(int duration) {
    for (final value in values) {
      if (duration >= value.duration) {
        return value;
      }
    }
    return AttackSpeed.values.last;
  }

  static int getPointTargetShoes({
    required int level,
    required ItemQuality quality,
  }) =>
      const {
        ItemQuality.Common: {
          1: 5,
          2: 10,
          3: 16,
        },
        ItemQuality.Unique: {
          1: 7,
          2: 13,
          3: 18,
        },
      }[quality]?[level] ??
      0;
}
