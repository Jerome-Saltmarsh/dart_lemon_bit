import '../../src.dart';
import 'package:collection/collection.dart';



enum AmuletItem {
  Weapon_Sword_1_Common(
      label: 'Short Sword',
      levelMin: 1,
      levelMax: 5,
      type: ItemType.Weapon,
      subType: WeaponType.Shortsword,
      performDuration: WeaponDuration.Normal,
      range: WeaponRange.ShortSword,
      damage: 3,
      quality: ItemQuality.Common,
      characteristics: Proficiencies(),
  ),
  Weapon_Sword_1_Rare(
    label: "Sharpened Short Sword",
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    skillType: SkillType.Strike,
    performDuration: WeaponDuration.Normal,
    range: WeaponRange.ShortSword,
    damage: 4,
    quality: ItemQuality.Rare,
    characteristics: Proficiencies(strength: 1),
  ),
  Weapon_Sword_1_Legendary(
    label: "Short Blade of Glen",
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    skillType: SkillType.Mighty_Strike,
    performDuration: WeaponDuration.Fast,
    range: WeaponRange.ShortSword,
    damage: 5,
    quality: ItemQuality.Legendary,
    characteristics: Proficiencies(strength: 2),
  ),
  Weapon_Staff_1_Of_Frost(
    label: 'Staff of Frost',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Frostball,
    performDuration: WeaponDuration.Slow,
    range: WeaponRange.Staff,
    damage: 2,
    quality: ItemQuality.Rare,
    characteristics: Proficiencies(),
  ),
  Weapon_Staff_1_Of_Fire(
    label: 'Staff of Fire',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Fireball,
    performDuration: WeaponDuration.Slow,
    range: WeaponRange.Staff,
    damage: 3,
    quality: ItemQuality.Rare,
    characteristics: Proficiencies(),
  ),
  Weapon_Staff_1_Legendary(
    label: 'Wooden Staff',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Fireball,
    performDuration: WeaponDuration.Slow,
    range: WeaponRange.Staff,
    damage: 5,
    quality: ItemQuality.Legendary,
    characteristics: Proficiencies(intelligence: 3),
  ),
  Weapon_Bow_1_Common(
    label: 'Common Short Bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Split_Shot,
    performDuration: WeaponDuration.Normal,
    range: WeaponRange.Short_Bow,
    damage: 2,
    quality: ItemQuality.Common,
    characteristics: Proficiencies(),
  ),
  Weapon_Bow_1_Rare(
    label: 'Rare Short Bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Split_Shot,
    performDuration: WeaponDuration.Normal,
    range: WeaponRange.Short_Bow,
    damage: 8,
    quality: ItemQuality.Rare,
    characteristics: Proficiencies(),
  ),
  Weapon_Bow_1_Legendary(
    label: 'Legendary Short Bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Split_Shot,
    performDuration: WeaponDuration.Fast,
    range: WeaponRange.Short_Bow,
    damage: 12,
    quality: ItemQuality.Legendary,
    characteristics: Proficiencies(),
  ),
  Helm_Warrior_1_Leather_Cap_Common(
    label: 'Leather Cap',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Leather_Cap,
    skillType: SkillType.Heal,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    characteristics: Proficiencies(strength: 1),
  ),
  Helm_Wizard_1_Pointed_Hat_Purple_Common(
    label: 'Crooked Hat',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Heal,
    type: ItemType.Helm,
    subType: HelmType.Pointed_Hat_Purple,
    maxHealth: 2,
    quality: ItemQuality.Common,
    regenMagic: 1,
    characteristics: Proficiencies(intelligence: 1),
  ),
  Helm_Rogue_1_Hood_Common(
    label: 'Feather Cap',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Warlock,
    type: ItemType.Helm,
    subType: HelmType.Feather_Cap,
    maxHealth: 3,
    quality: ItemQuality.Common,
    characteristics: Proficiencies(dexterity: 1),
  ),
  Helm_Warrior_2_Steel_Cap_Common(
    label: 'Steel Cap',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Steel_Cap,
    skillType: SkillType.Vampire,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    characteristics: Proficiencies(strength: 1),
  ),
  Helm_Wizard_2_Pointed_Hat_Black_Common(
    label: 'Pointed Hat',
    levelMin: 2,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Pointed_Hat_Black,
    skillType: SkillType.Warlock,
    maxMagic: 5,
    quality: ItemQuality.Common,
    regenMagic: 1,
    characteristics: Proficiencies(strength: 1),
  ),
  Helm_Rogue_2_Cape_Common(
    label: 'Cape',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Cape,
    skillType: SkillType.Vampire,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    characteristics: Proficiencies(strength: 1),
  ),
  Helm_Warrior_3_Full_Helm_Common(
    label: 'Full Helm',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Full_Helm,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    characteristics: Proficiencies(strength: 1),
  ),
  Helm_Wizard_3_Circlet_Common(
    label: 'Circlet',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Cowl,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    characteristics: Proficiencies(strength: 1),
  ),
  Helm_Rogue_3_Veil_Common(
    label: 'Veil',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Cape,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    characteristics: Proficiencies(strength: 1),
  ),
  Armor_Neutral_1_Common_Tunic(
    label: 'Common',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Tunic,
    quality: ItemQuality.Common,
    maxHealth: 1,
    skillType: SkillType.Heal,
    characteristics: Proficiencies(strength: 1),
  ),
  Armor_Warrior_1_Leather_Common(
    label: 'Leather',
    levelMin: 1,
    levelMax: 3,
    type: ItemType.Armor,
    subType: ArmorType.Leather,
    quality: ItemQuality.Common,
    maxHealth: 10,
    regenHealth: 1,
    skillType: SkillType.Mighty_Strike,
    characteristics: Proficiencies(strength: 1),
  ),
  Armor_Warrior_1_Leather_Rare(
    label: 'Leather',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Leather,
    quality: ItemQuality.Rare,
    maxHealth: 15,
    regenHealth: 1,
    skillType: SkillType.Mighty_Strike,
    characteristics: Proficiencies(strength: 1),
  ),
  Armor_Warrior_1_Leather_Legendary(
    label: 'Leather',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Leather,
    quality: ItemQuality.Legendary,
    maxHealth: 20,
    regenHealth: 2,
    skillType: SkillType.Mighty_Strike,
    characteristics: Proficiencies(strength: 1),
  ),
  Armor_Warrior_2_Chainmail_Common(
    label: 'Chainmail',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Chainmail,
    quality: ItemQuality.Common,
    maxHealth: 20,
    regenHealth: 2,
    characteristics: Proficiencies(strength: 1),
  ),
  Armor_Warrior_2_Chainmail_Rare(
    label: 'Chainmail',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Chainmail,
    quality: ItemQuality.Rare,
    maxHealth: 30,
    regenHealth: 2,
    characteristics: Proficiencies(strength: 1),
  ),
  Armor_Warrior_2_Chainmail_Legendary(
    label: 'Chainmail',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Chainmail,
    quality: ItemQuality.Legendary,
    maxHealth: 40,
    regenHealth: 3,
    characteristics: Proficiencies(strength: 1),
  ),
  Armor_Warrior_3_Platemail_Common(
    label: 'Platemail',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Platemail,
    quality: ItemQuality.Common,
    maxHealth: 30,
    regenHealth: 3,
    characteristics: Proficiencies(strength: 1),
  ),
  Armor_Warrior_3_Platemail_Rare(
    label: 'Platemail',
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Armor,
    subType: ArmorType.Platemail,
    quality: ItemQuality.Rare,
    maxHealth: 30,
    regenHealth: 3,
    characteristics: Proficiencies(strength: 1),
  ),
  Armor_Warrior_3_Platemail_Legendary(
    label: 'Platemail',
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Armor,
    subType: ArmorType.Platemail,
    quality: ItemQuality.Legendary,
    maxHealth: 30,
    regenHealth: 3,
    characteristics: Proficiencies(strength: 1),
  ),
  Armor_Wizard_1_Robe_Common(
    label: 'Robe',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Robes,
    quality: ItemQuality.Common,
    maxHealth: 5,
    regenMagic: 1,
    maxMagic: 5,
    characteristics: Proficiencies(intelligence: 2),
  ),
  Armor_Wizard_1_Robe_Rare(
    label: 'Robe',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Garb,
    quality: ItemQuality.Rare,
    maxHealth: 8,
    maxMagic: 10,
    characteristics: Proficiencies(intelligence: 3),
  ),
  Armor_Wizard_1_Robe_Legendary(
    label: 'Robe',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Attire,
    quality: ItemQuality.Legendary,
    maxHealth: 10,
    maxMagic: 15,
    characteristics: Proficiencies(intelligence: 5),
  ),
  Armor_Rogue_1_Cloak_Common(
    label: 'Cloak',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Common,
    maxHealth: 7,
    characteristics: Proficiencies(dexterity: 1),
  ),
  Armor_Rogue_1_Cloak_of_Frost(
    label: 'Cloak of Frost',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Rare,
    maxHealth: 10,
    skillType: SkillType.Ice_Arrow,
    characteristics: Proficiencies(dexterity: 2),
  ),
  Armor_Rogue_1_Cloak_of_Fire(
    label: 'Cloak of Fire',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Rare,
    maxHealth: 10,
    skillType: SkillType.Fire_Arrow,
    characteristics: Proficiencies(dexterity: 3, intelligence: 1),
  ),
  Armor_Rogue_1_Cloak_Legendary(
    label: 'Cloak',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Legendary,
    maxHealth: 12,
    characteristics: Proficiencies(strength: 1),
  ),
  Armor_Rogue_2_Mantle_Common(
    label: 'Mantle',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Mantle,
    quality: ItemQuality.Common,
    maxHealth: 9,
    characteristics: Proficiencies(dexterity: 1),
  ),
  Armor_Rogue_2_Mantle_Rare(
    label: 'Mantle',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Mantle,
    quality: ItemQuality.Rare,
    maxHealth: 9,
    characteristics: Proficiencies(dexterity: 1),
  ),
  Armor_Rogue_2_Mantle_Legendary(
    label: 'Mantle',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Mantle,
    quality: ItemQuality.Legendary,
    maxHealth: 9,
    characteristics: Proficiencies(dexterity: 1),
  ),
  Armor_Rogue_3_Shroud_Common(
    label: 'Shroud',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Shroud,
    quality: ItemQuality.Common,
    maxHealth: 9,
    characteristics: Proficiencies(dexterity: 1),
  ),
  Armor_Rogue_3_Shroud_Rare(
    label: 'Shroud',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Shroud,
    quality: ItemQuality.Rare,
    maxHealth: 9,
    characteristics: Proficiencies(dexterity: 1),
  ),
  Armor_Rogue_3_Shroud_Legendary(
    label: 'Shroud',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Shroud,
    quality: ItemQuality.Legendary,
    maxHealth: 9,
    characteristics: Proficiencies(dexterity: 1),
  ),
  Shoes_Warrior_1_Leather_Boots_Common(
    label: 'Leather Boots',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    quality: ItemQuality.Common,
    maxHealth: 5,
    runSpeed: -0.125,
    characteristics: Proficiencies(strength: 1),
  ),
  Shoes_Wizard_1_Black_Slippers_Common(
    label: 'Black Slippers',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Black_Slippers,
    quality: ItemQuality.Common,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Teleport,
    characteristics: Proficiencies(intelligence: 1),
  ),
  Shoes_Rogue_1_Treads_Common(
    label: 'Treads',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Treads,
    quality: ItemQuality.Common,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Teleport,
    characteristics: Proficiencies(dexterity: 1),
  ),
  Shoes_Warrior_2_Grieves_Common(
    label: 'Grieves',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Grieves,
    quality: ItemQuality.Common,
    maxHealth: 5,
    runSpeed: -0.125,
    characteristics: Proficiencies(strength: 1),
  ),
  Shoes_Wizard_2_Footwraps_Common(
    label: 'Footwraps',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Footwraps,
    quality: ItemQuality.Common,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Teleport,
    characteristics: Proficiencies(intelligence: 1),
  ),
  Shoes_Rogue_2_Striders_Common(
    label: 'Striders',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Striders,
    quality: ItemQuality.Common,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Teleport,
    characteristics: Proficiencies(dexterity: 1),
  ),
  Shoes_Warrior_3_Sabatons_Common(
    label: 'Sabatons',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Sabatons,
    quality: ItemQuality.Common,
    maxHealth: 5,
    runSpeed: -0.125,
    characteristics: Proficiencies(strength: 1),
  ),
  Shoes_Wizard_3_Soles_Common(
    label: 'Soles',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Soles,
    quality: ItemQuality.Common,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Teleport,
    characteristics: Proficiencies(intelligence: 1),
  ),
  Shoes_Rogue_3_Satin_Boots_Common(
    label: 'Satin_Boots',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Satin_Boots,
    quality: ItemQuality.Common,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Teleport,
    characteristics: Proficiencies(dexterity: 1),
  ),
  Consumable_Potion_Magic(
    label: 'a common tonic',
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Blue,
    levelMin: 0,
    levelMax: 99,
    quality: ItemQuality.Common,
    maxMagic: 20,
    characteristics: Proficiencies(),
  ),
  Consumable_Potion_Health(
    label: 'a common tonic',
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Red,
    levelMin: 0,
    levelMax: 99,
    quality: ItemQuality.Common,
    health: 20,
    characteristics: Proficiencies(),
  );

  /// the minimum level of a fiend that can drop this item
  final int levelMin;
  /// the maximum level of fiends that can drop this item
  final int levelMax;
  /// see item_type.dart in commons
  final int type;
  final int subType;
  final SkillType? skillType;
  final Proficiencies characteristics;
  final int? damage;
  final double? range;
  final double? radius;
  final int? performDuration;
  final int? health;
  final ItemQuality quality;
  final String label;
  final int? maxHealth;
  final int? maxMagic;
  final int? regenMagic;
  final int? regenHealth;
  final double? runSpeed;

  const AmuletItem({
    required this.type,
    required this.subType,
    required this.levelMin,
    required this.quality,
    required this.label,
    required this.characteristics,
    this.levelMax = 99,
    this.maxHealth = 0,
    this.maxMagic,
    this.regenMagic,
    this.regenHealth,
    this.skillType,
    this.damage,
    this.range,
    this.radius,
    this.performDuration,
    this.health,
    this.runSpeed,
  });

  bool get isWeapon => type == ItemType.Weapon;

  bool get isShoes => type == ItemType.Shoes;

  bool get isHelm => type == ItemType.Helm;

  bool get isConsumable => type == ItemType.Consumable;

  bool get isArmor => type == ItemType.Armor;


  static AmuletItem? findByName(String name) =>
      values.firstWhereOrNull((element) => element.name == name);

  static final Consumables = values
      .where((element) => element.isConsumable)
      .toList(growable: false);

  void validate() {
    if (isWeapon){
      if ((performDuration == null)) {
        throw Exception('$this performDuration of weapon cannot be null');
      }
      if ((performDuration! <= 0)) {
        throw Exception('$this performDuration of weapon must be greater than 0');
      }
      if (damage == null || damage! <= 0){
        throw Exception('$this.damage cannot cannot be null or 0');
      }
      if (range == null || range! <= 0){
        throw Exception('$this.range cannot cannot be null or 0');
      }
    } else {
      if ((performDuration ?? 0) > 0 && !this.isWeapon) {
        throw Exception('$this performDuration cannot be greater than 0 for non weapon');
      }
    }

  }
}

enum AmuletProficiency {
  Strength(pointsPerMaxHealth: 1, pointsPerMaxMagic: 3),
  Intelligence(pointsPerMaxHealth: 3, pointsPerMaxMagic: 1),
  Dexterity(pointsPerMaxHealth: 2, pointsPerMaxMagic: 2);

  final int pointsPerMaxHealth;
  final int pointsPerMaxMagic;

  const AmuletProficiency({
    required this.pointsPerMaxHealth,
    required this.pointsPerMaxMagic,
  });
}

class Proficiencies {
  final int strength;
  final int intelligence;
  final int dexterity;

  const Proficiencies({
    this.intelligence = 0,
    this.strength = 0,
    this.dexterity = 0,
  });

  int get(AmuletProficiency type) =>
      switch (type){
        AmuletProficiency.Strength => strength,
        AmuletProficiency.Intelligence => intelligence,
        AmuletProficiency.Dexterity => dexterity
      };
}


enum CasteType {
  Weapon,
  Caste,
  Passive,
}

enum ItemQuality {
  Legendary,
  Rare,
  Unique,
  Common,
}

enum WeaponClass {
  Sword,
  Staff,
  Bow;

  static WeaponClass fromWeaponType(int weaponType){
    if (WeaponType.isBow(weaponType)){
      return WeaponClass.Bow;
    }
    if (WeaponType.isSword(weaponType)){
      return WeaponClass.Sword;
    }
    if (WeaponType.isStaff(weaponType)){
      return WeaponClass.Staff;
    }
    throw Exception(
        'amuletPlayer.getWeaponTypeWeaponClass(weaponType: $weaponType)'
    );
  }
}

class WeaponRange {
  static const ShortSword = 40.0;
  static const BroadSword = 45.0;
  static const LongSword = 50.0;
  static const Staff = 45.0;
  static const Short_Bow = 150.0;
}

class WeaponDuration {
  static const Very_Fast = 20;
  static const Fast = 25;
  static const Normal = 30;
  static const Slow = 40;
  static const Very_Slow = 45;
}