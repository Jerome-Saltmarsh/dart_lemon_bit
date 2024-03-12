import 'package:lemon_math/src.dart';

import '../../src.dart';
import 'package:collection/collection.dart';

import '../isometric/damage_type.dart';

enum AmuletItem {
  Weapon_Sword_Short(
    label: 'Short Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Short,
    attackSpeed: 0.7,
    range: 0.2,
    damageMin: 0.75,
    damage: 0.45,
  ),
  Weapon_Sword_Broad(
    label: 'Broad Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Broad,
    attackSpeed: 0.5,
    range: 0.5,
    damage: 0.5,
    damageMin: 0.75,
  ),
  Weapon_Sword_Long(
    label: 'Long Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Long,
    attackSpeed: 0.4,
    range: 0.75,
    damageMin: 0.4,
    damage: 0.7,
  ),
  Weapon_Sword_Giant(
    label: 'Giant Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Giant,
    attackSpeed: 0.2,
    range: 1.0,
    damageMin: 0.5,
    damage: 0.9,
  ),
  Weapon_Bow_Short(
    label: 'Short Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Short,
    attackSpeed: 1.0,
    range: 0.25,
    damageMin: 0.9,
    damage: 0.25,
  ),
  Weapon_Bow_Reflex(
    label: 'Reflex Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Reflex,
    attackSpeed: 0.7,
    range: 0.4,
    damageMin: 0.5,
    damage: 0.35,
  ),
  Weapon_Bow_Composite(
    label: 'Composite Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Composite,
    attackSpeed: 0.5,
    range: 0.75,
    damageMin: 0.3,
    damage: 0.6,
  ),
  Weapon_Bow_Long(
    label: 'Lucky Long Bow of the Flame',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Long,
    attackSpeed: 0.3,
    range: 1.0,
    damageMin: 0.4,
    damage: 0.8,
  ),
  Weapon_Staff_Wand(
    label: 'Wand',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Wand,
    attackSpeed: 0.8,
    range: 0.15,
    damageMin: 0.5,
    damage: 0.1,
    skillSet: {
      SkillType.Magic_Regen: 0.5,
    },
  ),
  Weapon_Staff_Globe(
    label: 'Globe',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Globe,
    attackSpeed: 0.6,
    range: 0.4,
    damageMin: 0.2,
    damage: 0.35,
    skillSet: {
      SkillType.Magic_Regen: 0.5,
    },
  ),
  Weapon_Staff_Scepter(
    label: 'Scepter',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Scepter,
    attackSpeed: 0.5,
    range: 0.7,
    damageMin: 0.6,
    damage: 0.45,
    skillSet: {
      SkillType.Magic_Regen: 0.5,
    },
  ),
  Weapon_Staff_Long(
    label: 'Staff',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Long,
    attackSpeed: 0.4,
    range: 0.8,
    damageMin: 0.8,
    damage: 0.55,
    skillSet: {
      SkillType.Magic_Regen: 0.5,
    },
  ),
  Helm_Leather_Cap(
    label: 'Leather Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Leather_Cap,
    maxHealth: 0.5,
    maxMagic: 0,
    skillSet: {
      SkillType.Health_Regen: 0.5,
      SkillType.Critical_Hit: 0.5,
    },
  ),
  Helm_Steel_Cap(
    label: 'Steel Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Steel_Cap,
    maxHealth: 0.5,
    maxMagic: 0,
    skillSet: {
      SkillType.Critical_Hit: 1.5,
    },
  ),
  Helm_Full(
    label: 'Full Helm',
    slotType: SlotType.Helm,
    subType: HelmType.Full_Helm,
    maxHealth: 1.0,
    maxMagic: 0,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
    },
  ),
  Helm_Crooked_Hat(
    label: 'Crooked Hat',
    slotType: SlotType.Helm,
    subType: HelmType.Pointed_Hat_Purple,
    maxHealth: 0.0,
    maxMagic: 1.0,
    skillSet: {
      SkillType.Magic_Regen: 1.0,
    },
  ),
  Helm_Pointed_Hat(
    label: 'Pointed Hat',
    slotType: SlotType.Helm,
    subType: HelmType.Pointed_Hat_Black,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Magic_Regen: 0.5,
      SkillType.Health_Regen: 0.5,
    },
  ),
  Helm_Cowl(
    label: 'Cowl',
    slotType: SlotType.Helm,
    subType: HelmType.Cowl,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Magic_Steal: 1.0,
    },
  ),
  Helm_Feathered_Cap(
    label: 'Feather Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Feather_Cap,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Split_Shot: 1.0,
    },
  ),
  Helm_Cape(
    label: 'Cape',
    slotType: SlotType.Helm,
    subType: HelmType.Cape,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Agility: 1.0,
    },
  ),
  Helm_Veil(
    label: 'Veil',
    slotType: SlotType.Helm,
    subType: HelmType.Cape,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Ice_Arrow: 1.0,
    },
  ),
  Armor_Tunic(
    label: 'Tunic',
    slotType: SlotType.Armor,
    subType: ArmorType.Tunic,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Critical_Hit: 1.0,
    },
  ),
  Armor_Leather(
    label: 'Leather',
    slotType: SlotType.Armor,
    subType: ArmorType.Leather,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
    },
  ),
  Armor_Chainmail(
    label: 'Chainmail',
    slotType: SlotType.Armor,
    subType: ArmorType.Chainmail,
    maxHealth: 1.0,
    maxMagic: 0,
    skillSet: {
      SkillType.Area_Damage: 1.0,
    },
  ),
  Armor_Platemail(
    label: 'Platemail',
    slotType: SlotType.Armor,
    subType: ArmorType.Platemail,
    maxHealth: 0.75,
    maxMagic: 0.25,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
    },
  ),
  Armor_Robes(
    label: 'Robes',
    slotType: SlotType.Armor,
    subType: ArmorType.Robes,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Magic_Steal: 1.0,
    },
  ),
  Armor_Garb(
    label: 'Garb',
    slotType: SlotType.Armor,
    subType: ArmorType.Robes,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Heal: 1.0,
    },
  ),
  Armor_Cloak(
    label: 'Cloak',
    slotType: SlotType.Armor,
    subType: ArmorType.Cloak,
    maxHealth: 0.2,
    maxMagic: 0.8,
    skillSet: {
      SkillType.Agility: 1.0,
    },
  ),
  Armor_Mantle(
    label: 'Mantle',
    slotType: SlotType.Armor,
    subType: ArmorType.Mantle,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Shield: 1.0,
    },
  ),
  Armor_Shroud(
    label: 'Shroud',
    slotType: SlotType.Armor,
    subType: ArmorType.Shroud,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Health_Steal: 1.0,
    },
  ),
  Shoes_Leather_Boots(
    label: 'Leather Boots',
    slotType: SlotType.Shoes,
    subType: ShoeType.Leather_Boots,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
    },
  ),
  Shoes_Grieves(
    label: 'Grieves',
    slotType: SlotType.Shoes,
    subType: ShoeType.Grieves,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Scout: 1.0,
    },
  ),
  Shoes_Sabatons(
    label: 'Sabatons',
    slotType: SlotType.Shoes,
    subType: ShoeType.Sabatons,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
    },
  ),
  Shoes_Black_Slippers(
    label: 'Black Slippers',
    slotType: SlotType.Shoes,
    subType: ShoeType.Black_Slippers,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Magic_Regen: 1.0,
    },
  ),
  Shoes_Footwraps(
    label: 'Footwraps',
    slotType: SlotType.Shoes,
    subType: ShoeType.Footwraps,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Magic_Steal: 1.0,
    },
  ),
  Shoes_Soles(
    label: 'Soles',
    slotType: SlotType.Shoes,
    subType: ShoeType.Soles,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Magic_Regen: 1.0,
    },
  ),
  Shoes_Treads(
    label: 'Treads',
    slotType: SlotType.Shoes,
    subType: ShoeType.Treads,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Shoes_Striders(
    label: 'Striders',
    slotType: SlotType.Shoes,
    subType: ShoeType.Striders,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Critical_Hit: 1.0,
    },
  ),
  Shoes_Satin_Boots(
    label: 'Satin_Boots',
    slotType: SlotType.Shoes,
    subType: ShoeType.Satin_Boots,
    maxHealth: 0.5,
    maxMagic: 0.5,
    skillSet: {
      SkillType.Heal: 1.0,
    },
  ),
  Consumable_Potion_Magic(
    label: 'Magic Potion',
    slotType: SlotType.Consumable,
    subType: ConsumableType.Potion_Blue,
  ),
  Consumable_Potion_Health(
    label: 'Health Potion',
    slotType: SlotType.Consumable,
    subType: ConsumableType.Potion_Red,
  ),
  Special_Weapon_Frost_Wand(
      label: 'Frost Wand',
      slotType: SlotType.Weapon,
      subType: WeaponType.Staff_Wand,
      attackSpeed: 0.8,
      range: 0.15,
      damageMin: 0.9,
      damage: 0.1,
      quality: ItemQuality.Unique,
      skillSet: {
        SkillType.Frostball: 1.1,
      }),
  Special_Weapon_Flame_Wand(
      label: 'Flame Wand',
      slotType: SlotType.Weapon,
      subType: WeaponType.Staff_Wand,
      attackSpeed: 0.8,
      range: 0.15,
      damageMin: 0.9,
      damage: 0.1,
      quality: ItemQuality.Unique,
      skillSet: {
        SkillType.Frostball: 1.1,
      }),
  Special_Weapon_Vampire_Knife(
      label: 'Assassins Blade',
      slotType: SlotType.Weapon,
      subType: WeaponType.Sword_Short,
      attackSpeed: 0.75,
      range: 0.2,
      damage: 0.45,
      damageMin: 0.75,
      quality: ItemQuality.Unique,
      skillSet: {
        SkillType.Health_Steal: 1.0,
      }),
  Special_Weapon_Assassins_Blade(
      label: 'Assassins Blade',
      slotType: SlotType.Weapon,
      subType: WeaponType.Sword_Short,
      attackSpeed: 0.8,
      range: 0.2,
      damage: 0.55,
      damageMin: 0.75,
      quality: ItemQuality.Rare,
      skillSet: {
        SkillType.Critical_Hit: 2.0,
        SkillType.Agility: 1.0,
      }),
  Special_Weapon_Blizzard_Globe(
      label: 'Blizzard Globe',
      slotType: SlotType.Weapon,
      subType: WeaponType.Staff_Globe,
      attackSpeed: 0.6,
      range: 0.2,
      damage: 0.55,
      damageMin: 0.75,
      quality: ItemQuality.Rare,
      skillSet: {
        SkillType.Frostball: 2.0,
        SkillType.Magic_Steal: 1.0,
      }),
  Special_Weapon_Bow_Of_Destruction(
      label: 'Bow of Destruction',
      slotType: SlotType.Weapon,
      subType: WeaponType.Bow_Reflex,
      attackSpeed: 0.3,
      range: 0.6,
      damage: 0.75,
      damageMin: 0.5,
      quality: ItemQuality.Rare,
      skillSet: {
        SkillType.Critical_Hit: 2.0,
        SkillType.Agility: 1.0,
      }),
  Special_Helm_Igors_Hat(
      label: 'Igors Hat',
      slotType: SlotType.Helm,
      subType: HelmType.Pointed_Hat_Purple,
      maxMagic: 1.0,
      maxHealth: 1.0,
      quality: ItemQuality.Rare,
      skillSet: {
        SkillType.Fireball: 1.0,
      })
  ;

  /// see item_type.dart in commons
  final SlotType slotType;
  final int subType;
  final double? damageMin;

  /// between 0.0 and 1.0
  final double? damage;

  /// between 0.0 and 1.0
  final double? range;
  final double? attackSpeed;
  final ItemQuality quality;
  final String label;
  final double? maxHealth;
  final double? maxMagic;
  final Map<SkillType, double> skillSet;
  final Map<DamageType, double> resistances;

  const AmuletItem({
    required this.slotType,
    required this.subType,
    required this.label,
    this.quality = ItemQuality.Common,
    this.skillSet = const {},
    this.maxHealth,
    this.maxMagic,
    this.range,
    this.attackSpeed,
    this.damageMin,
    this.damage,
    this.resistances = const {},
  });

  bool get isWeapon => slotType == SlotType.Weapon;

  bool get isWeaponSword => isWeapon && WeaponType.isSword(subType);

  bool get isWeaponStaff => isWeapon && WeaponType.isStaff(subType);

  bool get isWeaponBow => isWeapon && WeaponType.isBow(subType);

  bool get isShoes => slotType == SlotType.Shoes;

  bool get isHelm => slotType == SlotType.Helm;

  bool get isConsumable => slotType == SlotType.Consumable;

  bool get isArmor => slotType == SlotType.Armor;

  double get quantify {
    const pointsPerDamage = 3;
    const pointsPerSkill = 2.0;
    final damageMax = (damage ?? 0) * pointsPerDamage * (attackSpeed ?? 0) * (range ?? 0);
    var total = 0.0;
    total += maxHealth ?? 0;
    total += maxMagic ?? 0;
    total += attackSpeed ?? 0;
    total += damageMax;
    total += (damageMin ?? 0) * damageMax;
    for (final entry in skillSet.entries) {
      total += entry.value * pointsPerSkill;
    }
    return total;
  }

  static AmuletItem? findByName(String name) =>
      values.firstWhereOrNull((element) => element.name == name);

  static final Consumables =
      values.where((element) => element.isConsumable).toList(growable: false);

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

  int getSkillTypeValue({
    required SkillType skillType,
    required int level,
  }) =>
      ((skillSet[skillType] ?? 0) * level).toInt();

  WeaponClass? get weaponClass {
    if (!isWeapon) {
      return null;
    }
    if (isWeaponBow) {
      return WeaponClass.Bow;
    }
    if (isWeaponStaff) {
      return WeaponClass.Staff;
    }
    if (isWeaponSword) {
      return WeaponClass.Sword;
    }
    throw Exception();
  }

  double? getMaxHealth(int level){
    final maxHealth = this.maxHealth;
    if (maxHealth == null) return null;
    final constraint = Stat_Health.get(slotType);
    final healthI = interpolateConstraint(constraint, maxHealth);
    return healthI * level;
  }

  double? getMaxMagic(int level){
    final maxHealth = this.maxMagic;
    if (maxHealth == null) return null;
    final constraint = Stat_Magic.get(slotType);
    final magicI = interpolateConstraint(constraint, maxHealth);
    return magicI * level;
  }

  double? getWeaponDamageMin(int level) {
    final damageMin = this.damageMin;
    if (damageMin == null) return null;
    final damage = getWeaponDamageMax(level);
    if (damage == null) return null;
    return damage * damageMin;
  }

  double? getWeaponDamageMax(int level) {
    final damage = this.damage;
    if (damage == null) return null;
    final damageI = interpolateConstraint(Stat_Weapon_Damage, damage);
    return damageI * level;
  }

  double? tryInterpolate(num start, num end, double? t) =>
      t == null ? null : interpolate(start, end, t);

  int getUpgradeCost(int level) =>
      (quantify * (level * level)).ceil();

  double interpolateConstraint(Constraint constraint, double i) =>
      interpolate(constraint.min, constraint.max, i);

  static const Stat_Health = SlotTypeConstraint(
      weapon: Constraint(min: 0, max: 20),
      helm: Constraint(min: 0, max: 20),
      armor: Constraint(min: 0, max: 20),
      shoes: Constraint(min: 0, max: 20),
      consumable: Constraint(min: 0, max: 0),
  );

  static const Stat_Magic = SlotTypeConstraint(
      weapon: Constraint(min: 0, max: 20),
      helm: Constraint(min: 0, max: 20),
      armor: Constraint(min: 0, max: 20),
      shoes: Constraint(min: 0, max: 20),
      consumable: Constraint(min: 0, max: 0),
  );

  static const Stat_Weapon_Damage = Constraint(min: 1, max: 20);
}

