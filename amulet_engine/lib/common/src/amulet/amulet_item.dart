import '../../src.dart';
import 'package:collection/collection.dart';

enum AmuletItem {
  Weapon_Sword_Short_Rusty(
    label: 'Rusted Short Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Short,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Very_Short,
    damageMin: 1,
    damageMax: 3,
    skillTypes: [
      SkillType.Mighty_Strike,
      SkillType.Wind_Cut,
      SkillType.Critical_Hit,
      SkillType.Shield,
    ],
  ),
  Weapon_Sword_Short(
    label: 'Short Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Short,
    attackSpeed: AttackSpeed.Very_Fast,
    range: WeaponRange.Very_Short,
    damageMin: 2,
    damageMax: 4,
    skillTypes: [
      SkillType.Mighty_Strike,
      SkillType.Wind_Cut,
      SkillType.Critical_Hit,
      SkillType.Shield,
    ],
  ),
  Weapon_Sword_Short_Unique(
    label: 'Sharpened Short Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Short,
    attackSpeed: AttackSpeed.Very_Fast,
    range: WeaponRange.Very_Short,
    damageMin: 3,
    damageMax: 5,
    skillTypes: [
      SkillType.Mighty_Strike,
      SkillType.Wind_Cut,
      SkillType.Critical_Hit,
      SkillType.Shield,
    ],
  ),
  Assassins_Blade(
    label: 'Assassins Blade',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Short,
    attackSpeed: AttackSpeed.Very_Fast,
    range: WeaponRange.Very_Short,
    damageMin: 3,
    damageMax: 5,
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
    damageMin: 4,
    damageMax: 6,
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
    damageMin: 4,
    damageMax: 8,
    skillTypes: [
      SkillType.Mighty_Strike,
      SkillType.Area_Damage,
      SkillType.Critical_Hit,
      SkillType.Shield,
      SkillType.Wind_Cut,
    ],
  ),
  Weapon_Sword_Long(
    label: 'Long Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Long,
    attackSpeed: AttackSpeed.Slow,
    range: WeaponRange.Long,
    damageMin: 6,
    damageMax: 12,
    skillTypes: [
      SkillType.Mighty_Strike,
      SkillType.Area_Damage,
      SkillType.Critical_Hit,
      SkillType.Shield,
      SkillType.Wind_Cut,
    ],
  ),
  Weapon_Sword_Giant(
    label: 'Giant Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Giant,
    attackSpeed: AttackSpeed.Very_Slow,
    range: WeaponRange.Very_Long,
    damageMin: 10,
    damageMax: 20,
    skillTypes: [
      SkillType.Mighty_Strike,
      SkillType.Area_Damage,
      SkillType.Critical_Hit,
      SkillType.Shield,
      SkillType.Wind_Cut,
    ],
  ),
  Weapon_Bow_Short(
    label: 'Short Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Short,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Very_Short,
    damageMin: 2,
    damageMax: 4,
    skillTypes: [
      ...SkillType.valuesBow,
      SkillType.Critical_Hit,
      SkillType.Shield,
    ],
  ),
  Weapon_Bow_Reflex(
    label: 'Reflex Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Reflex,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Short,
    damageMin: 3,
    damageMax: 6,
    skillTypes: [
      SkillType.Critical_Hit,
      SkillType.Shield,
      SkillType.Split_Shot,
      SkillType.Ice_Arrow,
      SkillType.Fire_Arrow,
    ],
  ),
  Weapon_Bow_Composite(
    label: 'Composite Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Composite,
    attackSpeed: AttackSpeed.Slow,
    range: WeaponRange.Long,
    damageMin: 5,
    damageMax: 8,
    skillTypes: [
      SkillType.Critical_Hit,
      SkillType.Shield,
      SkillType.Split_Shot,
      SkillType.Ice_Arrow,
      SkillType.Fire_Arrow,
    ],
  ),
  Weapon_Bow_Long(
    label: 'Long Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Long,
    attackSpeed: AttackSpeed.Very_Slow,
    range: WeaponRange.Very_Long,
    damageMin: 8,
    damageMax: 12,
    skillTypes: [
      SkillType.Critical_Hit,
      SkillType.Shield,
      SkillType.Split_Shot,
      SkillType.Ice_Arrow,
      SkillType.Fire_Arrow,
    ],
  ),
  Weapon_Staff_Wand(
    label: 'Wand',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Wand,
    attackSpeed: AttackSpeed.Very_Fast,
    range: WeaponRange.Very_Short,
    damageMin: 2,
    damageMax: 3,
    skillTypes: [
      SkillType.Critical_Hit,
      SkillType.Fireball,
      SkillType.Frostball,
      SkillType.Magic_Regen,
      SkillType.Warlock,
    ],
  ),
  Weapon_Staff_Globe(
    label: 'Globe',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Globe,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Short,
    damageMin: 4,
    damageMax: 6,
    skillTypes: [
      SkillType.Fireball,
      SkillType.Heal,
      SkillType.Magic_Regen,
      SkillType.Warlock,
    ],
  ),
  Weapon_Staff_Scepter(
      label: 'Scepter',
      slotType: SlotType.Weapon,
      subType: WeaponType.Staff_Scepter,
      attackSpeed: AttackSpeed.Slow,
      range: WeaponRange.Long,
      damageMin: 3,
      damageMax: 5,
      skillTypes: [
        SkillType.Fireball,
        SkillType.Heal,
        SkillType.Magic_Regen,
        SkillType.Warlock,
      ],
      ),
  Weapon_Staff_Long(
      label: 'Staff',
      slotType: SlotType.Weapon,
      subType: WeaponType.Staff_Long,
      attackSpeed: AttackSpeed.Very_Slow,
      range: WeaponRange.Very_Long,
      damageMin: 5,
      damageMax: 8,
      skillTypes: [
        SkillType.Fireball,
        SkillType.Heal,
        SkillType.Magic_Regen,
        SkillType.Warlock,
      ],
  ),
  Helm_Leather_Cap(
    label: 'Leather Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Leather_Cap,
    maxHealth: 5,
    maxMagic: 3,
    skillTypes: [
      SkillType.Health_Regen,
      SkillType.Vampire,
      SkillType.Critical_Hit,
      SkillType.Shield,
    ],
  ),
  Helm_Steel_Cap(
    label: 'Steel Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Steel_Cap,
    maxHealth: 8,
    skillTypes: [
      SkillType.Health_Regen,
      SkillType.Vampire,
      SkillType.Critical_Hit,
      SkillType.Shield,
    ],
  ),
  Helm_Full(
    label: 'Full Helm',
    slotType: SlotType.Helm,
    subType: HelmType.Full_Helm,
    maxHealth: 11,
    skillTypes: [
      SkillType.Health_Regen,
      SkillType.Vampire,
      SkillType.Critical_Hit,
      SkillType.Shield,
    ],
  ),
  Helm_Crooked_Hat(
    label: 'Crooked Hat',
    slotType: SlotType.Helm,
    subType: HelmType.Pointed_Hat_Purple,
    maxHealth: 1,
    maxMagic: 10,
    skillTypes: [
      SkillType.Magic_Regen,
      SkillType.Fireball,
      SkillType.Frostball,
      SkillType.Warlock,
    ],
  ),
  Helm_Pointed_Hat(
    label: 'Pointed Hat',
    slotType: SlotType.Helm,
    subType: HelmType.Pointed_Hat_Black,
    maxHealth: 2,
    maxMagic: 15,
    skillTypes: [
      SkillType.Magic_Regen,
      SkillType.Fireball,
      SkillType.Frostball,
      SkillType.Warlock,
    ],
  ),
  Helm_Cowl(
    label: 'Cowl',
    slotType: SlotType.Helm,
    subType: HelmType.Cowl,
    maxHealth: 2,
    maxMagic: 7,
    skillTypes: [
      SkillType.Magic_Regen,
      SkillType.Fireball,
      SkillType.Frostball,
      SkillType.Warlock,
    ],
  ),
  Helm_Feathered_Cap(
    label: 'Feather Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Feather_Cap,
    maxHealth: 3,
    skillTypes: [
      SkillType.Vampire,
      SkillType.Warlock,
      SkillType.Ice_Arrow,
      SkillType.Fire_Arrow,
      SkillType.Split_Shot,
    ],
  ),
  Helm_Cape(
    label: 'Cape',
    slotType: SlotType.Helm,
    subType: HelmType.Cape,
    maxHealth: 4,
    maxMagic: 2,
    skillTypes: [
      SkillType.Vampire,
      SkillType.Warlock,
      SkillType.Ice_Arrow,
      SkillType.Fire_Arrow,
      SkillType.Split_Shot,
    ],
  ),
  Helm_Veil(
    label: 'Veil',
    slotType: SlotType.Helm,
    subType: HelmType.Cape,
    maxHealth: 4,
    maxMagic: 2,
    skillTypes: [
      SkillType.Vampire,
      SkillType.Warlock,
      SkillType.Ice_Arrow,
      SkillType.Fire_Arrow,
      SkillType.Split_Shot,
    ],
  ),
  Armor_Tunic(
    label: 'Tunic',
    slotType: SlotType.Armor,
    subType: ArmorType.Tunic,
    maxHealth: 5,
    maxMagic: 5,
    skillTypes: [
      SkillType.Vampire,
      SkillType.Warlock,
      SkillType.Mighty_Strike,
      SkillType.Shield,
      SkillType.Critical_Hit,
      SkillType.Area_Damage,
    ],
  ),
  Armor_Leather(
    label: 'Leather',
    slotType: SlotType.Armor,
    subType: ArmorType.Leather,
    maxHealth: 10,
    skillTypes: [
      SkillType.Vampire,
      SkillType.Warlock,
      SkillType.Mighty_Strike,
      SkillType.Shield,
      SkillType.Critical_Hit,
      SkillType.Area_Damage,
    ],
  ),
  Armor_Chainmail(
    label: 'Chainmail',
    slotType: SlotType.Armor,
    subType: ArmorType.Chainmail,
    maxHealth: 20,
    skillTypes: [
      SkillType.Vampire,
      SkillType.Mighty_Strike,
      SkillType.Shield,
      SkillType.Critical_Hit,
      SkillType.Area_Damage,
    ],
  ),
  Armor_Platemail(
    label: 'Platemail',
    slotType: SlotType.Armor,
    subType: ArmorType.Platemail,
    maxHealth: 30,
    skillTypes: [
      SkillType.Vampire,
      SkillType.Mighty_Strike,
      SkillType.Shield,
      SkillType.Critical_Hit,
      SkillType.Area_Damage,
    ],
  ),
  Armor_Robes(
    label: 'Robes',
    slotType: SlotType.Armor,
    subType: ArmorType.Robes,
    maxHealth: 5,
    maxMagic: 10,
    skillTypes: [
      SkillType.Magic_Regen,
      SkillType.Warlock,
      SkillType.Fireball,
      SkillType.Frostball,
    ],
  ),
  Armor_Cloak(
    label: 'Cloak',
    slotType: SlotType.Armor,
    subType: ArmorType.Cloak,
    maxHealth: 10,
    maxMagic: 5,
    skillTypes: [
      SkillType.Vampire,
      SkillType.Mighty_Strike,
      SkillType.Shield,
      SkillType.Critical_Hit,
      SkillType.Area_Damage,
    ],
  ),
  Armor_Mantle(
    label: 'Mantle',
    slotType: SlotType.Armor,
    subType: ArmorType.Mantle,
    maxHealth: 6,
    maxMagic: 6,
    skillTypes: [
      SkillType.Vampire,
      SkillType.Critical_Hit,
      SkillType.Scout,
      SkillType.Agility,
    ],
  ),
  Armor_Shroud(
    label: 'Shroud',
    slotType: SlotType.Armor,
    subType: ArmorType.Shroud,
    maxHealth: 9,
    skillTypes: [
      SkillType.Vampire,
      SkillType.Mighty_Strike,
      SkillType.Shield,
      SkillType.Critical_Hit,
      SkillType.Area_Damage,
    ],
  ),
  Shoes_Leather_Boots(
    label: 'Leather Boots',
    slotType: SlotType.Shoes,
    subType: ShoeType.Leather_Boots,
    maxHealth: 5,
    skillTypes: [
      SkillType.Vampire,
      SkillType.Mighty_Strike,
      SkillType.Shield,
      SkillType.Critical_Hit,
      SkillType.Area_Damage,
    ],
  ),
  Shoes_Grieves(
    label: 'Grieves',
    slotType: SlotType.Shoes,
    subType: ShoeType.Grieves,
    maxHealth: 5,
    skillTypes: [
      SkillType.Scout,
      SkillType.Agility,
      SkillType.Area_Damage,
    ],
  ),
  Shoes_Warrior_3_Sabatons_Common(
    label: 'Sabatons',
    slotType: SlotType.Shoes,
    subType: ShoeType.Sabatons,
    maxHealth: 5,
    skillTypes: [
      SkillType.Scout,
      SkillType.Agility,
      SkillType.Area_Damage,
    ],
  ),
  Shoes_Black_Slippers(
    label: 'Black Slippers',
    slotType: SlotType.Shoes,
    subType: ShoeType.Black_Slippers,
    maxHealth: 1,
    maxMagic: 5,
    skillTypes: [
      SkillType.Scout,
      SkillType.Agility,
      SkillType.Area_Damage,
    ],
  ),
  Shoes_Footwraps(
    label: 'Footwraps',
    slotType: SlotType.Shoes,
    subType: ShoeType.Footwraps,
    maxHealth: 1,
    maxMagic: 5,
    skillTypes: [
      SkillType.Scout,
      SkillType.Agility,
      SkillType.Area_Damage,
    ],
  ),
  Shoes_Soles(
    label: 'Soles',
    slotType: SlotType.Shoes,
    subType: ShoeType.Soles,
    maxHealth: 1,
    maxMagic: 5,
    skillTypes: [
      SkillType.Scout,
      SkillType.Agility,
      SkillType.Area_Damage,
    ],
  ),
  Shoes_Treads(
    label: 'Treads',
    slotType: SlotType.Shoes,
    subType: ShoeType.Treads,
    maxHealth: 1,
    maxMagic: 5,
    skillTypes: [
      SkillType.Scout,
      SkillType.Agility,
      SkillType.Area_Damage,
    ],
  ),
  Shoes_Striders(
    label: 'Striders',
    slotType: SlotType.Shoes,
    subType: ShoeType.Striders,
    maxHealth: 1,
    maxMagic: 5,
    skillTypes: [
      SkillType.Scout,
      SkillType.Agility,
      SkillType.Area_Damage,
    ],
  ),
  Shoes_Satin_Boots(
    label: 'Satin_Boots',
    slotType: SlotType.Shoes,
    subType: ShoeType.Satin_Boots,
    maxHealth: 1,
    maxMagic: 5,
    skillTypes: [
      SkillType.Scout,
      SkillType.Agility,
      SkillType.Area_Damage,
    ],
  ),
  Consumable_Potion_Magic(
    label: 'Magic Potion',
    slotType: SlotType.Consumable,
    subType: ConsumableType.Potion_Blue,
    skillTypes: [],
  ),
  Consumable_Potion_Health(
      label: 'Health Potion',
      slotType: SlotType.Consumable,
      subType: ConsumableType.Potion_Red,
      skillTypes: [],
  );

  // int get levelMax => level + 1;

  /// the minimum level of a fiend that can drop this item
  // final int level;

  /// the maximum level of fiends that can drop this item

  /// see item_type.dart in commons
  final SlotType slotType;
  final int subType;
  // final double? damage;
  final double? damageMin;
  final double? damageMax;
  final WeaponRange? range;
  final AttackSpeed? attackSpeed;
  final ItemQuality quality;
  final String label;
  final int? maxHealth;
  final int? maxMagic;
  final List<SkillType> skillTypes;
  final Map<SkillType, int> skillSet;
  // final int skillPoints;

  const AmuletItem({
    required this.slotType,
    required this.subType,
    // required this.level,
    required this.label,
    this.skillTypes = const [],
    // this.skillPoints = 0,
    this.quality = ItemQuality.Common,
    this.skillSet = const {},
    this.maxHealth = 0,
    this.maxMagic,
    this.range,
    this.attackSpeed,
    this.damageMin,
    this.damageMax,
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

enum ItemQuality {
  Common(bonus: 1.0),
  Unique(bonus: 1.3),
  Rare(bonus: 1.61);

  final double bonus;
  const ItemQuality({required this.bonus});

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
