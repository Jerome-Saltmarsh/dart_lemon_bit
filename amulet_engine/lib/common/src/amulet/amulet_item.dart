import '../../src.dart';
import 'package:collection/collection.dart';



enum AmuletItem {
  Weapon_Sword_Short(
    label: 'Short Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Short,
    attackSpeed: 0.7,
    range: 0.2,
    damageMin: 0.5,
    damage: 0.25,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Assassins_Blade(
    label: 'Assassins Blade',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Short,
    attackSpeed: 0.75,
    range: 0.2,
    damage: 0.45,
    damageMin: 0.75,
    skillSet: {
      SkillType.Mighty_Strike: 1.1,
      SkillType.Critical_Hit: 1,
      SkillType.Agility: 1,
    },
    quality: ItemQuality.Unique,
  ),
  Unique_Weapon_Swift_Blade(
    label: 'Swift Blade',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Short,
    attackSpeed: 0.8,
    range: 0.2,
    damage: 0.55,
    damageMin: 0.75,
    skillSet: {
      SkillType.Critical_Hit: 1,
      SkillType.Agility: 1,
      SkillType.Vampire: 1,
    },
    quality: ItemQuality.Rare,
  ),
  Weapon_Sword_Broad(
    label: 'Broad Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Broad,
    attackSpeed: 0.5,
    range: 0.5,
    damage: 0.5,
    damageMin: 0.75,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Sword_Long(
    label: 'Long Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Long,
    attackSpeed: 0.4,
    range: 0.75,
    damageMin: 0.4,
    damage: 0.7,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Sword_Giant(
    label: 'Giant Sword',
    slotType: SlotType.Weapon,
    subType: WeaponType.Sword_Giant,
    attackSpeed: 0.2,
    range: 1.0,
    damageMin: 0.5,
    damage: 0.85,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Bow_Short(
    label: 'Short Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Short,
    attackSpeed: 1.0,
    range: 0.25,
    damageMin: 0.9,
    damage: 0.25,
    skillSet: {
      SkillType.Split_Shot: 1.0,
      SkillType.Vampire: 0.8,
    },
  ),
  Weapon_Bow_Reflex(
    label: 'Reflex Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Reflex,
    attackSpeed: 0.7,
    range: 0.4,
    damageMin: 0.5,
    damage: 0.35,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Bow_Composite(
    label: 'Composite Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Composite,
    attackSpeed: 0.5,
    range: 0.75,
    damageMin: 0.5,
    damage: 0.45,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Bow_Long(
    label: 'Long Bow',
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Long,
    attackSpeed: 0.4,
    range: 1.0,
    damageMin: 0.75,
    damage: 0.65,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Staff_Wand(
    label: 'Wand',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Wand,
    attackSpeed: 0.7,
    range: 0.1,
    damageMin: 0.85,
    damage: 0.25,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
  ),
  Weapon_Staff_Globe(
    label: 'Globe',
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Globe,
    attackSpeed: 0.6,
    range: 0.4,
    damageMin: 0.5,
    damage: 0.35,
    skillSet: {
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
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
      SkillType.Mighty_Strike: 1.0,
      SkillType.Critical_Hit: 0.8,
    },
      ),
  Weapon_Staff_Long(
      label: 'Staff',
      slotType: SlotType.Weapon,
      subType: WeaponType.Staff_Long,
      attackSpeed: 0.4,
      range: 1.0,
      damageMin: 0.8,
    damage: 0.55,
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
  final int? maxHealth;
  final int? maxMagic;
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

  double get quantify {
    const pointsPerDamage = 3;

    var total = 0.0;
    total += maxHealth ?? 0;
    total += maxMagic ?? 0;
    total += (damage ?? 0) * pointsPerDamage;
    total += (damageMin ?? 0) * pointsPerDamage;
    total += range ?? 0;
    total += attackSpeed ?? 0;
    for (final entry in skillSet.entries){
      total += entry.value;
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
  })=> ((skillSet[skillType] ?? 0) * level).toInt();

  WeaponClass? get weaponClass {
     if (!isWeapon){
       return null;
     }
     if (isWeaponBow){
       return WeaponClass.Bow;
     }
     if (isWeaponStaff){
       return WeaponClass.Staff;
     }
     if (isWeaponSword){
       return WeaponClass.Sword;
     }
     throw Exception();
  }
}

