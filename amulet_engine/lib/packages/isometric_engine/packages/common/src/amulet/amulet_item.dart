import '../../src.dart';
import 'package:collection/collection.dart';

// weapon
    // bow
      // short [x]
      // composite
      // reflex
    // sword
      // short [x]
      // broad
      // long
    // staff
      // wooden [x]
      // glass
      // crystal

// armour
 // neutral
    // tunic [x]
 // knight
    // leather [x]
    // chainmail [x]
    // platemail [x]
 // wizard
    // robes [x]
    // garb [x]
    // attire
 // rogue
    // cloak [x]
    // mantle
    // shroud

// helm
  // warrior
    // leather cap [x]
    // steel cap [x]
    // full helm [x]
  // wizard
    // pointed hat purple [x]
    // pointed hat black [x]
    // cowl
  // rogue
    // feather cap [x]
    // hood
    // cape

// shoes
  // warrior
    // leather boots [x]
    // grieves [x]
    // sabatons
  // wizard
    // black_slippers [x]
    // footwraps
    // soles
  // rogue
    // treads [x]
    // striders
    // satin_boots

// stash
  // scalemail
  // splint
  // banded
  // brigandine
  // veil
  // diadem
  // turban
  // circlet
  // great helm
  // crest
  // broom (weapon type wizard)
  // wand (weapon type wizard)
  // dagger (weapon type rogue)

enum AmuletItem {
  Weapon_Sword_1_Common(
      label: 'Short Sword',
      levelMin: 1,
      levelMax: 5,
      type: ItemType.Weapon,
      subType: WeaponType.Shortsword,
      performDuration: 25,
      range: 40,
      damage: 3,
      quality: ItemQuality.Common,
      characteristics: Characteristics(knight: 1),
      weaponSkill: Skill(
          skillType: SkillType.Strike,
          damageMin: 2,
          damageMax: 4,
          performDuration: 25,
      ),
  ),
  Weapon_Sword_1_Rare(
    label: "Short Sword",
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    skillType: SkillType.Strike,
    performDuration: 25,
    damage: 4,
    range: 45,
    quality: ItemQuality.Rare,
    characteristics: Characteristics(knight: 1),
    weaponSkill: Skill(
      skillType: SkillType.Strike,
      damageMin: 4,
      damageMax: 7,
      performDuration: 25,
    ),
  ),
  Weapon_Sword_1_Legendary(
    label: "Short Blade of Glen",
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    skillType: SkillType.Strike,
    performDuration: 22,
    damage: 5,
    range: 45,
    quality: ItemQuality.Legendary,
    characteristics: Characteristics(knight: 1),
  ),
  Weapon_Staff_1_Common(
    label: 'Wooden Staff',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Fireball,
    performDuration: 35,
    range: 40,
    damage: 2,
    quality: ItemQuality.Common,
    characteristics: Characteristics(knight: 1),
  ),
  Weapon_Staff_1_Of_Frost(
    label: 'Staff of Frost',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Frostball,
    skill: Skill(
        skillType: SkillType.Frostball,
        damageMin: 3,
        damageMax: 5,
        performDuration: 20,
    ),
    performDuration: 35,
    range: 50,
    damage: 3,
    quality: ItemQuality.Rare,
    characteristics: Characteristics(knight: 1),
  ),
  Weapon_Staff_1_Of_Fire(
    label: 'Staff of Fire',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Fireball,
    performDuration: 35,
    range: 50,
    damage: 3,
    quality: ItemQuality.Rare,
    characteristics: Characteristics(knight: 1),
  ),
  Weapon_Staff_1_Legendary(
    label: 'Wooden Staff',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Fireball,
    performDuration: 35,
    range: 80,
    damage: 7,
    quality: ItemQuality.Legendary,
    characteristics: Characteristics(knight: 1),
  ),
  Weapon_Bow_1_Common(
    label: 'Common Short Bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Split_Shot,
    performDuration: 25,
    range: 125,
    damage: 2,
    quality: ItemQuality.Common,
    characteristics: Characteristics(knight: 1),
  ),
  Weapon_Bow_1_Rare(
    label: 'Rare Short Bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Split_Shot,
    performDuration: 25,
    range: 135,
    damage: 8,
    quality: ItemQuality.Rare,
    characteristics: Characteristics(knight: 1),
  ),
  Weapon_Bow_1_Legendary(
    label: 'Legendary Short Bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Split_Shot,
    performDuration: 32,
    range: 150,
    damage: 12,
    quality: ItemQuality.Legendary,
    characteristics: Characteristics(knight: 1),
  ),
  Helm_Warrior_1_Leather_Cap_Common(
    label: 'Leather Cap',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Leather_Cap,
    performDuration: 25,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    characteristics: Characteristics(knight: 1),
  ),
  Helm_Wizard_1_Pointed_Hat_Purple_Common(
    label: 'Crooked Hat',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Heal,
    type: ItemType.Helm,
    subType: HelmType.Pointed_Hat_Purple,
    performDuration: 25,
    maxHealth: 2,
    quality: ItemQuality.Common,
    regenMagic: 1,
    skillMagicCost: 3,
    characteristics: Characteristics(knight: 1),
  ),
  Helm_Rogue_1_Hood_Common(
    label: 'Feather Cap',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Split_Shot,
    type: ItemType.Helm,
    subType: HelmType.Feather_Cap,
    performDuration: 25,
    maxHealth: 3,
    quality: ItemQuality.Common,
    skillMagicCost: 4,
    characteristics: Characteristics(knight: 1),
  ),
  Helm_Warrior_2_Steel_Cap_Common(
    label: 'Steel Cap',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Steel_Cap,
    performDuration: 25,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    characteristics: Characteristics(knight: 1),
  ),
  Helm_Wizard_2_Pointed_Hat_Black_Common(
    label: 'Pointed Hat',
    levelMin: 2,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Pointed_Hat_Black,
    performDuration: 25,
    maxMagic: 5,
    quality: ItemQuality.Common,
    regenMagic: 1,
    characteristics: Characteristics(knight: 1),
  ),
  Helm_Rogue_2_Cape_Common(
    label: 'Cape',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Cape,
    performDuration: 25,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    characteristics: Characteristics(knight: 1),
  ),
  Helm_Warrior_3_Full_Helm_Common(
    label: 'Full Helm',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Full_Helm,
    performDuration: 25,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    characteristics: Characteristics(knight: 1),
  ),
  Helm_Wizard_3_Circlet_Common(
    label: 'Circlet',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Cowl,
    performDuration: 25,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    characteristics: Characteristics(knight: 1),
  ),
  Helm_Rogue_3_Veil_Common(
    label: 'Veil',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Cape,
    performDuration: 25,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    characteristics: Characteristics(knight: 1),
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
    characteristics: Characteristics(knight: 1),
  ),
  Armor_Warrior_1_Leather_Common(
    label: 'Leather',
    levelMin: 1,
    levelMax: 3,
    type: ItemType.Armor,
    subType: ArmorType.Leather,
    quality: ItemQuality.Common,
    maxHealth: 10,
    skillMagicCost: 6,
    regenHealth: 1,
    skillType: SkillType.Mighty_Swing,
    characteristics: Characteristics(knight: 1),
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
    skillType: SkillType.Mighty_Swing,
    characteristics: Characteristics(knight: 1),
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
    skillType: SkillType.Mighty_Swing,
    characteristics: Characteristics(knight: 1),
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
    characteristics: Characteristics(knight: 1),
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
    characteristics: Characteristics(knight: 1),
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
    characteristics: Characteristics(knight: 1),
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
    characteristics: Characteristics(knight: 1),
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
    characteristics: Characteristics(knight: 1),
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
    characteristics: Characteristics(knight: 1),
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
    characteristics: Characteristics(knight: 1),
  ),
  Armor_Wizard_1_Robe_Rare(
    label: 'Robe',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Robes,
    quality: ItemQuality.Rare,
    maxHealth: 8,
    maxMagic: 10,
    characteristics: Characteristics(knight: 1),
  ),
  Armor_Wizard_1_Robe_Legendary(
    label: 'Robe',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Robes,
    quality: ItemQuality.Legendary,
    maxHealth: 10,
    maxMagic: 15,
    characteristics: Characteristics(knight: 1),
  ),
  Armor_Rogue_1_Cloak_Common(
    label: 'Cloak',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Common,
    maxHealth: 7,
    characteristics: Characteristics(knight: 1),
  ),
  Armor_Rogue_1_Cloak_Rare(
    label: 'Cloak',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Rare,
    maxHealth: 9,
    characteristics: Characteristics(knight: 1),
  ),
  Armor_Rogue_1_Cloak_Legendary(
    label: 'Cloak',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Legendary,
    maxHealth: 12,
    characteristics: Characteristics(knight: 1),
  ),
  Armor_Rogue_2_Mantle_Common(
    label: 'Mantle',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Mantle,
    quality: ItemQuality.Common,
    maxHealth: 9,
    characteristics: Characteristics(knight: 1),
  ),
  Armor_Rogue_2_Mantle_Rare(
    label: 'Mantle',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Mantle,
    quality: ItemQuality.Rare,
    maxHealth: 9,
    characteristics: Characteristics(knight: 1),
  ),
  Armor_Rogue_2_Mantle_Legendary(
    label: 'Mantle',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Mantle,
    quality: ItemQuality.Legendary,
    maxHealth: 9,
    characteristics: Characteristics(knight: 1),
  ),
  Armor_Rogue_3_Shroud_Common(
    label: 'Shroud',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Shroud,
    quality: ItemQuality.Common,
    maxHealth: 9,
    characteristics: Characteristics(knight: 1),
  ),
  Armor_Rogue_3_Shroud_Rare(
    label: 'Shroud',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Shroud,
    quality: ItemQuality.Rare,
    maxHealth: 9,
    characteristics: Characteristics(knight: 1),
  ),
  Armor_Rogue_3_Shroud_Legendary(
    label: 'Shroud',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Shroud,
    quality: ItemQuality.Legendary,
    maxHealth: 9,
    characteristics: Characteristics(knight: 1),
  ),
  Shoes_Warrior_1_Leather_Boots_Common(
    label: 'Leather Boots',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    performDuration: 25,
    quality: ItemQuality.Common,
    maxHealth: 5,
    runSpeed: -0.125,
    characteristics: Characteristics(knight: 1),
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
    skillMagicCost: 6,
    characteristics: Characteristics(knight: 1),
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
    skillMagicCost: 6,
    performDuration: 20,
    characteristics: Characteristics(knight: 1),
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
    characteristics: Characteristics(knight: 1),
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
    performDuration: 20,
    skillMagicCost: 6,
    characteristics: Characteristics(knight: 1),
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
    performDuration: 20,
    skillMagicCost: 6,
    characteristics: Characteristics(knight: 1),
  ),
  Shoes_Warrior_3_Sabatons_Common(
    label: 'Sabatons',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Sabatons,
    performDuration: 25,
    quality: ItemQuality.Common,
    maxHealth: 5,
    runSpeed: -0.125,
    characteristics: Characteristics(knight: 1),
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
    skillMagicCost: 6,
    characteristics: Characteristics(knight: 1),
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
    skillMagicCost: 6,
    characteristics: Characteristics(knight: 1),
  ),
  Consumable_Potion_Magic(
    label: 'a common tonic',
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Blue,
    levelMin: 0,
    levelMax: 99,
    quality: ItemQuality.Common,
    maxMagic: 20,
    characteristics: Characteristics(),
  ),
  Consumable_Potion_Health(
    label: 'a common tonic',
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Red,
    levelMin: 0,
    levelMax: 99,
    quality: ItemQuality.Common,
    health: 20,
    characteristics: Characteristics(),
  );

  /// the minimum level of a fiend that can drop this item
  final int levelMin;
  /// the maximum level of fiends that can drop this item
  final int levelMax;
  /// see item_type.dart in commons
  final int type;
  final int subType;
  final SkillType? skillType;
  final Skill? skill;
  final Skill? weaponSkill;
  final Characteristics characteristics;
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
  final int? skillMagicCost;
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
    this.weaponSkill,
    this.damage,
    this.range,
    this.radius,
    this.skill,
    this.performDuration,
    this.health,
    this.skillMagicCost,
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
}

// Thief;
// Healer;
// Elf;
// Warlock;
enum CharacteristicType {
  Wizard(pointsPerMaxHealth: 3, pointsPerMaxMagic: 1),
  Knight(pointsPerMaxHealth: 1, pointsPerMaxMagic: 3),
  Rogue(pointsPerMaxHealth: 2, pointsPerMaxMagic: 2);

  final int pointsPerMaxHealth;
  final int pointsPerMaxMagic;

  const CharacteristicType({
    required this.pointsPerMaxHealth,
    required this.pointsPerMaxMagic,
  });
}

class Characteristics {
  final int knight;
  final int wizard;
  final int rogue;

  const Characteristics({
    this.wizard = 0,
    this.knight = 0,
    this.rogue = 0,
  });

  int get(CharacteristicType type) =>
      switch (type){
        CharacteristicType.Knight => knight,
        CharacteristicType.Wizard => wizard,
        CharacteristicType.Rogue => rogue
      };
}

enum SkillType {
  None(casteType: CasteType.Caste, magicCost: 0, range: 0, casteDuration: 0),
  Strike(casteType: CasteType.Weapon, magicCost: 0),
  Shoot_Arrow(casteType: CasteType.Weapon, magicCost: 0),
  Mighty_Swing(casteType: CasteType.Weapon, magicCost: 3),
  Terrify(casteType: CasteType.Caste, magicCost: 5, casteDuration: 30, range: 125),
  Frostball(casteType: CasteType.Caste, magicCost: 4, casteDuration: 25, range: 125, damageMin: 3, damageMax: 5),
  Fireball(casteType: CasteType.Caste, magicCost: 5, casteDuration: 30, range: 150, damageMin: 4, damageMax: 6),
  Explode(casteType: CasteType.Caste, magicCost: 7, casteDuration: 35, range: 125),
  Firestorm(casteType: CasteType.Caste, magicCost: 10, casteDuration: 40, range: 150),
  Freeze_Target(casteType: CasteType.Caste, magicCost: 8, casteDuration: 20, range: 125),
  Freeze_Area(casteType: CasteType.Caste, magicCost: 5, casteDuration: 25, range: 150),
  Heal(casteType: CasteType.Caste, magicCost: 4, casteDuration: 30, range: 0),
  Teleport(casteType: CasteType.Caste, magicCost: 5, casteDuration: 35, range: 250),
  Entangle(casteType: CasteType.Weapon, magicCost: 4, casteDuration: 40),
  Split_Shot(casteType: CasteType.Weapon, magicCost: 4);

  final CasteType casteType;
  final int magicCost;
  /// if null the weapon perform duration is used
  final int? casteDuration;
  /// if null the weapon range is used
  final double? range;
  final int? damageMin;
  final int? damageMax;

  const SkillType({
    required this.casteType,
    required this.magicCost,
    this.casteDuration,
    this.damageMin,
    this.damageMax,
    this.range,
  });

  static void validate() {
    for (final skillType in values){
      if (skillType.casteType == CasteType.Caste){
        if (skillType.range == null){
          throw Exception('$skillType.range cannot be null');
        }
        if (skillType.casteDuration == null){
          throw Exception('$skillType.casteDuration cannot be null');
        }
      }
    }
  }
}

enum CasteType {
  Weapon,
  Caste,
}

enum ItemQuality {
  Legendary,
  Rare,
  Common,
}

enum ClassType {
  Warrior,
  Wizard,
  Rogue,
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

class Skill {
  final SkillType skillType;
  final int damageMin;
  final int damageMax;
  final int performDuration;

  const Skill({
    required this.skillType,
    required this.damageMin,
    required this.damageMax,
    required this.performDuration,
  });
}