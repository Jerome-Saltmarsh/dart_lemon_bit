import '../../src.dart';

enum AmuletItem {
  Weapon_Sword_Short(
    label: 'Short Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Short,
    attackSpeed: 0.7,
    range: 0.2,
    damageMin: 0.75,
    damage: 0.45,
    attackSkill: SkillType.Slash,
  ),
  Weapon_Sword_Broad(
    label: 'Broad Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Broad,
    attackSpeed: 0.5,
    range: 0.5,
    damage: 0.5,
    damageMin: 0.75,
    attackSkill: SkillType.Slash,
  ),
  Weapon_Sword_Long(
    label: 'Long Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Long,
    attackSpeed: 0.4,
    range: 0.75,
    damageMin: 0.4,
    damage: 0.7,
    attackSkill: SkillType.Slash,
  ),
  Weapon_Sword_Giant(
    label: 'Giant Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Giant,
    attackSpeed: 0.2,
    range: 1.0,
    damageMin: 0.5,
    damage: 0.9,
    attackSkill: SkillType.Slash,
  ),
  Weapon_Bow_Short(
    label: 'Short Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Short,
    attackSpeed: 1.0,
    range: 0.25,
    damageMin: 0.9,
    damage: 0.25,
    attackSkill: SkillType.Shoot_Arrow,
  ),
  Weapon_Bow_Reflex(
    label: 'Reflex Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Reflex,
    attackSpeed: 0.7,
    range: 0.4,
    damageMin: 0.5,
    damage: 0.35,
    attackSkill: SkillType.Shoot_Arrow,
  ),
  Weapon_Bow_Composite(
    label: 'Composite Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Composite,
    attackSpeed: 0.5,
    range: 0.75,
    damageMin: 0.3,
    damage: 0.6,
    attackSkill: SkillType.Shoot_Arrow,
  ),
  Weapon_Bow_Long(
    label: 'Lucky Long Bow of the Flame',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Long,
    attackSpeed: 0.3,
    range: 1.0,
    damageMin: 0.4,
    damage: 0.8,
    attackSkill: SkillType.Shoot_Arrow,
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
    attackSkill: SkillType.Bludgeon,
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
    attackSkill: SkillType.Bludgeon,
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
    attackSkill: SkillType.Bludgeon,
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
    attackSkill: SkillType.Bludgeon,
  ),
  Helm_Leather_Cap(
    label: 'Leather Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Leather_Cap,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Health_Regen: 0.25,
      SkillType.Critical_Hit: 0.25,
    },
  ),
  Helm_Steel_Cap(
    label: 'Steel Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Steel_Cap,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Wind_Cut: 0.5,
    },
  ),
  Helm_Full(
    label: 'Full Helm',
    slotType: SlotType.Helm,
    subType: HelmType.Full_Helm,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Mighty_Strike: 0.5,
    },
  ),
  Helm_Crooked_Hat(
    label: 'Crooked Hat',
    slotType: SlotType.Helm,
    subType: HelmType.Pointed_Hat_Purple,
    skillSet: {
      SkillType.Max_Magic: 1.0,
      SkillType.Magic_Regen: 0.5,
    },
  ),
  Helm_Pointed_Hat(
    label: 'Pointed Hat',
    slotType: SlotType.Helm,
    subType: HelmType.Pointed_Hat_Black,
    skillSet: {
      SkillType.Max_Magic: 1.0,
      SkillType.Magic_Steal: 0.5,
    },
  ),
  Helm_Cowl(
    label: 'Cowl',
    slotType: SlotType.Helm,
    subType: HelmType.Cowl,
    skillSet: {
      SkillType.Max_Magic: 1.0,
      SkillType.Frostball: 0.5,
    },
  ),
  Helm_Feathered_Cap(
    label: 'Feather Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Feather_Cap,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Split_Shot: 0.5,
    },
  ),
  Helm_Cape(
    label: 'Cape',
    slotType: SlotType.Helm,
    subType: HelmType.Cape,
    skillSet: {
      SkillType.Agility: 0.5,
    },
  ),
  Helm_Veil(
    label: 'Veil',
    slotType: SlotType.Helm,
    subType: HelmType.Cape,
    skillSet: {
      SkillType.Health_Steal: 0.5,
    },
  ),
  Armor_Tunic(
    label: 'Tunic',
    slotType: SlotType.Armor,
    subType: ArmorType.Tunic,
    skillSet: {
      SkillType.Critical_Hit: 1.0,
    },
  ),
  Armor_Leather(
    label: 'Leather',
    slotType: SlotType.Armor,
    subType: ArmorType.Leather,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Mighty_Strike: 1.0,
    },
  ),
  Armor_Chainmail(
    label: 'Chainmail',
    slotType: SlotType.Armor,
    subType: ArmorType.Chainmail,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Area_Damage: 1.0,
    },
  ),
  Armor_Platemail(
    label: 'Platemail',
    slotType: SlotType.Armor,
    subType: ArmorType.Platemail,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Mighty_Strike: 1.0,
    },
  ),
  Armor_Robes(
    label: 'Robes',
    slotType: SlotType.Armor,
    subType: ArmorType.Robes,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Magic_Steal: 1.0,
    },
  ),
  Armor_Garb(
    label: 'Garb',
    slotType: SlotType.Armor,
    subType: ArmorType.Robes,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Heal: 1.0,
    },
  ),
  Armor_Cloak(
    label: 'Cloak',
    slotType: SlotType.Armor,
    subType: ArmorType.Cloak,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Agility: 1.0,
    },
  ),
  Armor_Mantle(
    label: 'Mantle',
    slotType: SlotType.Armor,
    subType: ArmorType.Mantle,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Shield: 1.0,
    },
  ),
  Armor_Shroud(
    label: 'Shroud',
    slotType: SlotType.Armor,
    subType: ArmorType.Shroud,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Health_Steal: 1.0,
    },
  ),
  Shoes_Leather_Boots(
    label: 'Leather Boots',
    slotType: SlotType.Shoes,
    subType: ShoeType.Leather_Boots,
    skillSet: {
      SkillType.Max_Health: 1.0,
    },
  ),
  Shoes_Grieves(
    label: 'Grieves',
    slotType: SlotType.Shoes,
    subType: ShoeType.Grieves,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Wind_Cut: 0.5,
    },
  ),
  Shoes_Sabatons(
    label: 'Sabatons',
    slotType: SlotType.Shoes,
    subType: ShoeType.Sabatons,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Mighty_Strike: 1.0,
    },
  ),
  Shoes_Black_Slippers(
    label: 'Black Slippers',
    slotType: SlotType.Shoes,
    subType: ShoeType.Black_Slippers,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Magic_Regen: 1.0,
    },
  ),
  Shoes_Footwraps(
    label: 'Footwraps',
    slotType: SlotType.Shoes,
    subType: ShoeType.Footwraps,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Magic_Steal: 0.5,
    },
  ),
  Shoes_Soles(
    label: 'Soles',
    slotType: SlotType.Shoes,
    subType: ShoeType.Soles,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Magic_Regen: 1.0,
    },
  ),
  Shoes_Treads(
    label: 'Treads',
    slotType: SlotType.Shoes,
    subType: ShoeType.Treads,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Agility: 1.0,
    },
  ),
  Shoes_Striders(
    label: 'Striders',
    slotType: SlotType.Shoes,
    subType: ShoeType.Striders,
    skillSet: {
      SkillType.Max_Health: 1.0,
      SkillType.Scout: 1.0,
    },
  ),
  Shoes_Satin_Boots(
    label: 'Satin_Boots',
    slotType: SlotType.Shoes,
    subType: ShoeType.Satin_Boots,
    skillSet: {
      SkillType.Max_Health: 1.0,
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
      attackSkill: SkillType.Bludgeon,
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
      attackSkill: SkillType.Bludgeon,
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
      attackSkill: SkillType.Slash,
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
      attackSkill: SkillType.Slash,
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
      attackSkill: SkillType.Bludgeon,
      skillSet: {
        SkillType.Frostball: 2.0,
        SkillType.Magic_Steal: 1.0,
      }),
  Special_Weapon_Bow_Of_Destruction(
      label: 'Bow of Destruction',
      slotType: SlotType.Weapon,
      subType: WeaponType.Bow_Reflex,
      attackSkill: SkillType.Shoot_Arrow,
      attackSpeed: 0.3,
      range: 0.6,
      damage: 0.75,
      damageMin: 0.5,
      quality: ItemQuality.Rare,
      skillSet: {
        SkillType.Critical_Hit: 2.0,
        SkillType.Agility: 1.0,
      }),
  Unique_Helm_Of_Fireball(
      label: 'Scorched Hat',
      slotType: SlotType.Helm,
      subType: HelmType.Pointed_Hat_Purple,
      quality: ItemQuality.Unique,
      skillSet: {
        SkillType.Max_Health: 1.0,
        SkillType.Max_Magic: 1.0,
        SkillType.Fireball: 1.5,
      }),
  Unique_Helm_Of_Frostball(
      label: 'Frosted Hat',
      slotType: SlotType.Helm,
      subType: HelmType.Pointed_Hat_Purple,
      quality: ItemQuality.Unique,
      skillSet: {
        SkillType.Max_Health: 1.0,
        SkillType.Frostball: 1.5,
      }),
  Unique_Helm_Of_Magic_Regen(
      label: 'Frosted Hat',
      slotType: SlotType.Helm,
      subType: HelmType.Pointed_Hat_Purple,
      quality: ItemQuality.Unique,
      skillSet: {
        SkillType.Max_Health: 1.0,
        SkillType.Magic_Regen: 1.5,
      }),
  Rare_Helm_Of_Fireball(
      label: 'Lost Hat of Flame',
      slotType: SlotType.Helm,
      subType: HelmType.Pointed_Hat_Purple,
      quality: ItemQuality.Rare,
      skillSet: {
        SkillType.Max_Health: 1.0,
        SkillType.Fireball: 2.5,
      }),
  Rare_Helm_Of_Frostball(
      label: 'Sacred Hat of the Tempest',
      slotType: SlotType.Helm,
      subType: HelmType.Pointed_Hat_Purple,
      quality: ItemQuality.Rare,
      skillSet: {
        SkillType.Max_Health: 1.0,
        SkillType.Max_Magic: 1.0,
        SkillType.Frostball: 2.5,
      }),
  Rare_Helm_Of_Magic_Regen(
      label: 'Legendary Hat of Magic',
      slotType: SlotType.Helm,
      subType: HelmType.Pointed_Hat_Purple,
      quality: ItemQuality.Rare,
      skillSet: {
        SkillType.Max_Health: 1.0,
        SkillType.Magic_Regen: 2.5,
      }),
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
  final Map<SkillType, double> skillSet;
  final Map<DamageType, double> resistances;
  final SkillType? attackSkill;

  const AmuletItem({
    required this.slotType,
    required this.subType,
    required this.label,
    this.attackSkill,
    this.quality = ItemQuality.Common,
    this.skillSet = const {},
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
    total += attackSpeed ?? 0;
    total += damageMax;
    total += (damageMin ?? 0) * damageMax;
    for (final entry in skillSet.entries) {
      total += entry.value * pointsPerSkill;
    }
    return total;
  }

  static AmuletItem? findByName(String name) {
    for (final value in values){
      if (value.name == name) return value;
    }
    return null;
  }

  bool isValid() {
    return !isWeapon || attackSkill != null;
  }

  static final Consumables =
  values.where((element) => element.isConsumable).toList(growable: false);

  double? getMaxHealth(int level) =>
      getSkillTypeValue(
          skillType: SkillType.Max_Magic,
          level: level,
      ) * 5;

  double? getMaxMagic(int level) =>
      getSkillTypeValue(
          skillType: SkillType.Max_Health,
          level: level,
      ) * 5;

  int? tryGetUpgradeCost(int? level){
    if (level == null) return null;
    return getUpgradeCost(level);
  }

  int getUpgradeCost(int level) => (level * level * quantify).floor();

  int getSkillTypeValue({required SkillType skillType, required int level}){
    final skillValue = skillSet[skillType];
    if (skillValue == null) return 0;
    return (skillValue * level).floor();
  }

  double? getWeaponDamageMax(int level){
    return level * Damage_Per_Level;
  }

  double? getWeaponDamageMin(int level){
    final damageMin = this.damageMin;
    if (damageMin == null) return null;
    final damageMax = getWeaponDamageMax(level);
    if (damageMax == null) return null;
    return damageMax * damageMin;
  }

  static const Constraint_Weapon_Damage = Constraint(min: 1, max: 20);
  static const Health_Per_Level = 5.0;
  static const Magic_Per_Level = 5.0;
  static const Damage_Per_Level = 1.0;


}


