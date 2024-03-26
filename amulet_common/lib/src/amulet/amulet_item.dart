import 'package:lemon_math/src.dart';

import '../../src.dart';



enum AmuletItem {
  Weapon_Sword_Short(
    label: 'Short Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Short,
    maxLevel: 5,
    skills: {
      SkillType.Slash: Constraint(min: 0.1, max: 0.3),
      SkillType.Attack_Speed: Constraint(min: 0.3, max: 0.3),
      SkillType.Attack_Range: Constraint(min: 0.3, max: 0.3),
    }
  ),
  Weapon_Sword_Broad(
    label: 'Broad Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Broad,
    skills: {
      SkillType.Slash: Constraint(min: 0.2, max: 0.4),
      SkillType.Attack_Speed: Constraint(min: 0.2, max: 0.2),
      SkillType.Attack_Range: Constraint(min: 0.5, max: 0.5),
    }
  ),
  Weapon_Sword_Long(
    label: 'Long Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Long,
      skills: {
        SkillType.Slash: Constraint(min: 0.3, max: 0.5),
        SkillType.Attack_Speed: Constraint(min: 0.3, max: 0.3),
        SkillType.Attack_Range: Constraint(min: 0.6, max: 0.6),
      }
  ),
  Weapon_Sword_Giant(
    label: 'Giant Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Giant,
    skills: {
        SkillType.Slash: Constraint(min: 0.4, max: 0.6),
        SkillType.Attack_Speed: Constraint(min: 0.2, max: 0.3),
        SkillType.Attack_Range: Constraint(min: 0.7, max: 0.9),
    }
  ),
  Weapon_Bow_Short(
    label: 'Short Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Short,
    skills: {
      SkillType.Shoot_Arrow: Constraint(min: 0.1, max: 0.3),
      SkillType.Attack_Speed: Constraint(min: 0.3, max: 0.5),
      SkillType.Attack_Range: Constraint(min: 0.25, max: 0.4),
    },
  ),
  Weapon_Bow_Reflex(
    label: 'Reflex Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Reflex,
    skills: {
      SkillType.Shoot_Arrow: Constraint(min: 0.1, max: 0.3),
      SkillType.Attack_Speed: Constraint(min: 0.7, max: 0.8),
      SkillType.Attack_Range: Constraint(min: 0.25, max: 0.25),
    },
  ),
  Weapon_Bow_Composite(
    label: 'Composite Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Composite,
    skills: {
      SkillType.Shoot_Arrow: Constraint(min: 0.1, max: 0.3),
      SkillType.Attack_Speed: Constraint(min: 0.7, max: 0.8),
      SkillType.Attack_Range: Constraint(min: 0.25, max: 0.25),
    },
  ),
  Weapon_Bow_Long(
    label: 'Long Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Long,
    skills: {
      SkillType.Shoot_Arrow: Constraint(min: 0.1, max: 0.3),
      SkillType.Attack_Speed: Constraint(min: 0.7, max: 0.8),
      SkillType.Attack_Range: Constraint(min: 0.25, max: 0.25),
    },
  ),
  Weapon_Staff_Wand(
    label: 'Wand',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Wand,
    skills: {
      SkillType.Ice_Ball: Constraint(min: 0.1, max: 0.4),
      SkillType.Max_Magic: Constraint(min: 0.2, max: 0.5),
    },
  ),
  Weapon_Staff_Globe(
    label: 'Globe',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Globe,
    skills: {
      SkillType.Ice_Ball: Constraint(min: 0.1, max: 0.4),
      SkillType.Max_Magic: Constraint(min: 0.3, max: 0.6),
    },
  ),
  Weapon_Staff_Scepter(
    label: 'Scepter',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Scepter,
    skills: {
      SkillType.Ice_Ball: Constraint(min: 0.1, max: 0.4),
      SkillType.Max_Magic: Constraint(min: 0.7, max: 0.8),
    },
  ),
  Weapon_Staff_Long(
    label: 'Staff',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Long,
    skills: {
      SkillType.Ice_Ball: Constraint(min: 0.1, max: 0.4),
      SkillType.Max_Magic: Constraint(min: 0.7, max: 0.8),
    },
  ),
  Helm_Leather_Cap(
    label: 'Leather Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Leather_Cap,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Helm_Steel_Cap(
    label: 'Steel Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Steel_Cap,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Helm_Full(
    label: 'Full Helm',
    slotType: SlotType.Helm,
    subType: HelmType.Full_Helm,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Helm_Crooked_Hat(
    label: 'Crooked Hat',
    slotType: SlotType.Helm,
    subType: HelmType.Pointed_Hat_Purple,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Helm_Pointed_Hat(
    label: 'Pointed Hat',
    slotType: SlotType.Helm,
    subType: HelmType.Pointed_Hat_Black,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Helm_Cowl(
    label: 'Cowl',
    slotType: SlotType.Helm,
    subType: HelmType.Cowl,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Helm_Feathered_Cap(
    label: 'Feather Cap',
    slotType: SlotType.Helm,
    subType: HelmType.Feather_Cap,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Helm_Cape(
    label: 'Cape',
    slotType: SlotType.Helm,
    subType: HelmType.Cape,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Helm_Veil(
    label: 'Veil',
    slotType: SlotType.Helm,
    subType: HelmType.Cape,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Armor_Tunic(
    label: 'Tunic',
    slotType: SlotType.Armor,
    subType: ArmorType.Tunic,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Armor_Leather(
    label: 'Leather',
    slotType: SlotType.Armor,
    subType: ArmorType.Leather,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Armor_Chainmail(
    label: 'Chainmail',
    slotType: SlotType.Armor,
    subType: ArmorType.Chainmail,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Armor_Platemail(
    label: 'Platemail',
    slotType: SlotType.Armor,
    subType: ArmorType.Platemail,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Armor_Robes(
    label: 'Robes',
    slotType: SlotType.Armor,
    subType: ArmorType.Robes,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Armor_Garb(
    label: 'Garb',
    slotType: SlotType.Armor,
    subType: ArmorType.Robes,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Armor_Cloak(
    label: 'Cloak',
    slotType: SlotType.Armor,
    subType: ArmorType.Cloak,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Armor_Mantle(
    label: 'Mantle',
    slotType: SlotType.Armor,
    subType: ArmorType.Mantle,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Armor_Shroud(
    label: 'Shroud',
    slotType: SlotType.Armor,
    subType: ArmorType.Shroud,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Shoes_Leather_Boots(
    label: 'Leather Boots',
    slotType: SlotType.Shoes,
    subType: ShoeType.Leather_Boots,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Shoes_Grieves(
    label: 'Grieves',
    slotType: SlotType.Shoes,
    subType: ShoeType.Grieves,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Shoes_Sabatons(
    label: 'Sabatons',
    slotType: SlotType.Shoes,
    subType: ShoeType.Sabatons,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Shoes_Black_Slippers(
    label: 'Black Slippers',
    slotType: SlotType.Shoes,
    subType: ShoeType.Black_Slippers,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Shoes_Footwraps(
    label: 'Footwraps',
    slotType: SlotType.Shoes,
    subType: ShoeType.Footwraps,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Shoes_Soles(
    label: 'Soles',
    slotType: SlotType.Shoes,
    subType: ShoeType.Soles,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Shoes_Treads(
    label: 'Treads',
    slotType: SlotType.Shoes,
    subType: ShoeType.Treads,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Shoes_Striders(
    label: 'Striders',
    slotType: SlotType.Shoes,
    subType: ShoeType.Striders,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
    },
  ),
  Shoes_Satin_Boots(
    label: 'Satin_Boots',
    slotType: SlotType.Shoes,
    subType: ShoeType.Satin_Boots,
    skills: {
      SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
      SkillType.Health_Regen: Constraint(min: 0.1, max: 0.4),
      SkillType.Critical_Hit: Constraint(min: 0.1, max: 0.4),
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
  Consumable_Meat(
    label: 'Meat',
    slotType: SlotType.Consumable,
    subType: ConsumableType.Meat_Drumstick,
  ),
  Consumable_Sapphire (
    label: 'Sapphire',
    slotType: SlotType.Consumable,
    subType: ConsumableType.Sapphire,
  ),
  Consumable_Gold (
    label: 'Gold',
    slotType: SlotType.Consumable,
    subType: ConsumableType.Gold,
  ),
  Special_Weapon_Frost_Wand(
      label: 'Frost Wand',
      slotType: SlotType.Weapon,
      subType: WeaponType.Staff_Wand,
      quality: ItemQuality.Unique,
      skills: {
        SkillType.Bludgeon: Constraint(min: 0.1, max: 0.4),
        SkillType.Fire_Ball: Constraint(min: 0.1, max: 0.4),
        SkillType.Magic_Steal: Constraint(min: 0.1, max: 0.4),
      },
  ),

  Special_Weapon_Flame_Wand(
      label: 'Flame Wand',
      slotType: SlotType.Weapon,
      subType: WeaponType.Staff_Wand,
      quality: ItemQuality.Unique,
      skills: {
        SkillType.Bludgeon: Constraint(min: 0.1, max: 0.4),
        SkillType.Fire_Ball: Constraint(min: 0.1, max: 0.4),
        SkillType.Magic_Steal: Constraint(min: 0.1, max: 0.4),
      },
  ),
  Special_Weapon_Vampire_Knife(
      label: 'Assassins Blade',
      slotType: SlotType.Weapon,
      subType: WeaponType.Sword_Short,
      quality: ItemQuality.Unique,
      skills: {
        SkillType.Bludgeon: Constraint(min: 0.1, max: 0.4),
        SkillType.Fire_Ball: Constraint(min: 0.1, max: 0.4),
        SkillType.Magic_Steal: Constraint(min: 0.1, max: 0.4),
      },
    ),
  Special_Weapon_Assassins_Blade(
      label: 'Assassins Blade',
      slotType: SlotType.Weapon,
      subType: WeaponType.Sword_Short,
      quality: ItemQuality.Rare,
      skills: {
        SkillType.Bludgeon: Constraint(min: 0.1, max: 0.4),
        SkillType.Fire_Ball: Constraint(min: 0.1, max: 0.4),
        SkillType.Magic_Steal: Constraint(min: 0.1, max: 0.4),
      },
  ),
  Special_Weapon_Blizzard_Globe(
      label: 'Blizzard Globe',
      slotType: SlotType.Weapon,
      subType: WeaponType.Staff_Globe,
      quality: ItemQuality.Rare,
      skills: {
        SkillType.Bludgeon: Constraint(min: 0.1, max: 0.4),
        SkillType.Fire_Ball: Constraint(min: 0.1, max: 0.4),
        SkillType.Magic_Steal: Constraint(min: 0.1, max: 0.4),
      },
  ),
  Special_Weapon_Bow_Of_Destruction(
      label: 'Bow of Destruction',
      slotType: SlotType.Weapon,
      subType: WeaponType.Bow_Reflex,
      quality: ItemQuality.Rare,
      skills: {
        SkillType.Bludgeon: Constraint(min: 0.1, max: 0.4),
        SkillType.Fire_Ball: Constraint(min: 0.1, max: 0.4),
        SkillType.Magic_Steal: Constraint(min: 0.1, max: 0.4),
      },
  ),
  Unique_Helm_Of_Fireball(
      label: 'Scorched Hat',
      slotType: SlotType.Helm,
      subType: HelmType.Pointed_Hat_Purple,
      quality: ItemQuality.Unique,
      skills: {
        SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
        SkillType.Max_Magic: Constraint(min: 0.1, max: 0.4),
        SkillType.Fire_Ball: Constraint(min: 0.1, max: 0.4),
      },
  ),
  Unique_Helm_Of_Frostball(
      label: 'Frosted Hat',
      slotType: SlotType.Helm,
      subType: HelmType.Pointed_Hat_Purple,
      quality: ItemQuality.Unique,
      skills: {
        SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
        SkillType.Max_Magic: Constraint(min: 0.1, max: 0.4),
        SkillType.Fire_Ball: Constraint(min: 0.1, max: 0.4),
      },
  ),
  Unique_Helm_Of_Magic_Regen(
      label: 'Frosted Hat',
      slotType: SlotType.Helm,
      subType: HelmType.Pointed_Hat_Purple,
      quality: ItemQuality.Unique,
      skills: {
        SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
        SkillType.Max_Magic: Constraint(min: 0.1, max: 0.4),
        SkillType.Fire_Ball: Constraint(min: 0.1, max: 0.4),
      },
  ),
  Rare_Helm_Of_Fireball(
      label: 'Lost Hat of Flame',
      slotType: SlotType.Helm,
      subType: HelmType.Pointed_Hat_Purple,
      quality: ItemQuality.Rare,
      skills: {
        SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
        SkillType.Max_Magic: Constraint(min: 0.1, max: 0.4),
        SkillType.Fire_Ball: Constraint(min: 0.1, max: 0.4),
      },
  ),
  Rare_Helm_Of_Frostball(
      label: 'Sacred Hat of the Tempest',
      slotType: SlotType.Helm,
      subType: HelmType.Pointed_Hat_Purple,
      quality: ItemQuality.Rare,
      skills: {
        SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
        SkillType.Max_Magic: Constraint(min: 0.1, max: 0.4),
        SkillType.Fire_Ball: Constraint(min: 0.1, max: 0.4),
      },
  ),
  Rare_Helm_Of_Magic_Regen(
      label: 'Legendary Hat of Magic',
      slotType: SlotType.Helm,
      subType: HelmType.Pointed_Hat_Purple,
      quality: ItemQuality.Rare,
      skills: {
        SkillType.Max_Health: Constraint(min: 0.1, max: 0.4),
        SkillType.Max_Magic: Constraint(min: 0.1, max: 0.4),
        SkillType.Fire_Ball: Constraint(min: 0.1, max: 0.4),
      },
  ),
  ;

  /// see item_type.dart in commons
  final SlotType slotType;
  final int subType;
  final ItemQuality quality;
  final String label;
  // final Map<SkillType, double> skillSet;
  // final Map<SkillType, int> skillBase;
  final Map<SkillType, Constraint<double>> skills;
  final int maxLevel;

  const AmuletItem({
    required this.slotType,
    required this.subType,
    required this.label,
    this.quality = ItemQuality.Common,
    this.skills = const {},
    this.maxLevel = 5,
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
    return (quantifyMin + quantifyMax).toDouble();
  }

  double get quantifyMin {
    var total = 0.0;
    for (final skill in skills.entries) {
      total += skill.value.min;
    }
    return total;
  }

  double get quantifyMax {
    var total = 0.0;
    for (final skill in skills.entries) {
      total += skill.value.max;
    }

    return total;
  }

  static AmuletItem? findByName(String name) {
    for (final value in values){
      if (value.name == name) return value;
    }
    return null;
  }

  SkillType? get attackSkill {
    for (final entry in skills.entries){
      if (entry.key.isBaseAttack) {
        return entry.key;
      }
    }
    return null;
  }

  bool isValid() {
    if (isWeapon){
      final attackSkill = this.attackSkill;
      if (attackSkill == null){
        throw Exception('$this attackSkill is null');
      }
    }

    return !isWeapon || attackSkill != null;
  }

  static final Consumables =
  values.where((element) => element.isConsumable).toList(growable: false);

  double? getMaxHealth(int level) =>
      getSkillTypeLevel(
          skillType: SkillType.Max_Magic,
          level: level,
      ) * 5;

  double? getMaxMagic(int level) =>
      getSkillTypeLevel(
          skillType: SkillType.Max_Health,
          level: level,
      ) * 5;

  int? tryGetUpgradeCost(int? level){
    if (level == null) return null;
    return getUpgradeCost(level);
  }

  int getUpgradeCost(int level) => (level * level * quantify).floor();

  int getSkillTypeLevel({
    required SkillType skillType,
    required int level,
  }) {
    final entry = skills[skillType];
    if (entry == null) return 0;
    final levelClamped = level.clamp(1, maxLevel);
    final i = levelClamped / maxLevel;
    final t = interpolate(entry.min, entry.max, i);
    final maxLevelI = interpolate(0, skillType.maxLevel, t);
    return maxLevelI.floor();
  }

  double getRange(int level){
    final i = level / SkillType.Attack_Range.maxLevel;

    if (isWeaponBow) {
      return interpolate(
          Constraint_Range_Bow.min,
          Constraint_Range_Bow.max,
          i,
      );
    }

    if (isWeaponSword) {
      return interpolate(
        Constraint_Range_Sword.min,
        Constraint_Range_Sword.max,
          i,
      );
    }

    if (isWeaponStaff) {
      return interpolate(
        Constraint_Range_Staff.min,
        Constraint_Range_Staff.max,
          i,
      );
    }

    return 0;
  }

  static const Constraint_Weapon_Damage = Constraint(min: 1, max: 20);
  static const Constraint_Range_Sword = Constraint(min: 50, max: 100);
  static const Constraint_Range_Staff = Constraint(min: 40, max: 80);
  static const Constraint_Range_Bow = Constraint(min: 150, max: 250);
  static const Health_Per_Level = 5.0;
  static const Magic_Per_Level = 5.0;
  static const Damage_Per_Level = 1.0;


}


