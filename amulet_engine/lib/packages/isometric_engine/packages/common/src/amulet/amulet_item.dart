import '../../src.dart';
import 'package:collection/collection.dart';

// armour
 // neutral
    // tunic [x]
 // knight
    // leather [x]
    // chainmail [x]
    // platemail [x]
 // wizard
    // robes [ ]
    // garb
    // attire
 // rogue
    // cloak
    // mantle
    // shroud

// helm
  // warrior
    // leather cap
    // steel cap [x]
    // steel helm
  // wizard
    // pointed hat purple [x]
    // pointed hat black [x]
    // cowl
  // rogue
    // feathered cap
    // hood
    // cape

// shoes
  // warrior
    // boots
    // grieves
    // sabatons
  // wizard
    // slippers
    // footwraps
    // soles
  // rogue
    // treads
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
      description: 'A particularly sharp short sword',
      levelMin: 1,
      levelMax: 5,
      type: ItemType.Weapon,
      subType: WeaponType.Shortsword,
      skillType: SkillType.Strike,
      performDuration: 25,
      range: 40,
      damageMin: 0,
      damageMax: 5,
      quality: ItemQuality.Common,
  ),
  Weapon_Sword_1_Rare(
    label: "a basic short sword",
    description: 'An extra short sword',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    skillType: SkillType.Strike,
    performDuration: 25,
    damageMin: 2,
    damageMax: 7,
    range: 45,
    quality: ItemQuality.Rare,
  ),
  Weapon_Sword_1_Legendary(
    label: "Short Blade of Glen",
    description: 'An extra short sword',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    skillType: SkillType.Strike,
    performDuration: 22,
    damageMin: 3,
    damageMax: 9,
    range: 45,
    quality: ItemQuality.Legendary,
  ),
  Weapon_Staff_1_Common(
    label: 'Wooden Staff',
    description: 'a faint heat emanates from within',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Fireball,
    performDuration: 35,
    range: 40,
    damageMin: 2,
    damageMax: 5,
    quality: ItemQuality.Common,
  ),
  Weapon_Staff_1_Rare(
    label: 'Wooden Staff',
    description: 'a faint heat emanates from within',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Fireball,
    performDuration: 35,
    range: 50,
    damageMin: 3,
    damageMax: 7,
    quality: ItemQuality.Rare,
  ),
  Weapon_Staff_1_Legendary(
    label: 'Wooden Staff',
    description: 'a faint heat emanates from within',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Fireball,
    skillLevel: 1,
    performDuration: 35,
    range: 80,
    damageMin: 3,
    damageMax: 7,
    quality: ItemQuality.Legendary,
  ),
  Weapon_Bow_1_Common(
    label: 'Common Short Bow',
    description: 'A worn out bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Arrow,
    performDuration: 25,
    range: 125,
    damageMin: 2,
    damageMax: 5,
    quality: ItemQuality.Common,
  ),
  Weapon_Bow_1_Rare(
    label: 'Rare Short Bow',
    description: 'This bow was crafted from a stronger wood',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Arrow,
    performDuration: 25,
    range: 135,
    damageMin: 3,
    damageMax: 8,
    quality: ItemQuality.Rare,
  ),
  Weapon_Bow_1_Legendary(
    label: 'Legendary Short Bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Arrow,
    performDuration: 32,
    range: 150,
    damageMin: 5,
    damageMax: 12,
    quality: ItemQuality.Legendary,
  ),
  Helm_Warrior_1_Leather_Cap_Common(
    label: 'Leather Cap',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Might,
    skillLevel: 1,
    type: ItemType.Helm,
    subType: HelmType.Leather_Cap,
    performDuration: 25,
    defense: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
  ),
  Helm_Wizard_1_Pointed_Hat_Purple_Common(
    label: 'Crooked Hat',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Heal,
    type: ItemType.Helm,
    subType: HelmType.Pointed_Hat_Purple,
    performDuration: 25,
    defense: 2,
    quality: ItemQuality.Common,
    regenMagic: 1,
    skillMagicCost: 3,
  ),
  Helm_Rogue_1_Hood_Common(
    label: 'Hood',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Invisible,
    skillLevel: 1,
    type: ItemType.Helm,
    subType: HelmType.Hood,
    performDuration: 25,
    defense: 3,
    quality: ItemQuality.Common,
    skillMagicCost: 4,
  ),
  Helm_Warrior_2_Steel_Cap_Common(
    label: 'Steel Cap',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Might,
    skillLevel: 1,
    type: ItemType.Helm,
    subType: HelmType.Steel_Cap,
    performDuration: 25,
    defense: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
  ),
  Helm_Wizard_2_Pointed_Hat_Black_Common(
    label: 'Pointed Hat',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Might,
    skillLevel: 1,
    type: ItemType.Helm,
    subType: HelmType.Pointed_Hat_Black,
    performDuration: 25,
    defense: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
  ),
  Helm_Rogue_2_Cape_Common(
    label: 'Cape',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Might,
    skillLevel: 1,
    type: ItemType.Helm,
    subType: HelmType.Cape,
    performDuration: 25,
    defense: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
  ),
  Helm_Warrior_3_Steel_Helm_Common(
    label: 'Steel Helm',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Might,
    skillLevel: 1,
    type: ItemType.Helm,
    subType: HelmType.Steel_Helm,
    performDuration: 25,
    defense: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
  ),
  Helm_Wizard_3_Circlet_Common(
    label: 'Circlet',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Might,
    skillLevel: 1,
    type: ItemType.Helm,
    subType: HelmType.Circlet,
    performDuration: 25,
    defense: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
  ),
  Helm_Rogue_3_Veil_Common(
    label: 'Veil',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Might,
    skillLevel: 1,
    type: ItemType.Helm,
    subType: HelmType.Veil,
    performDuration: 25,
    defense: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
  ),
  Armor_Neutral_1_Common_Tunic(
    label: 'Common',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Tunic,
    quality: ItemQuality.Common,
    defense: 1,
  ),
  Armor_Warrior_1_Leather_Common(
    label: 'Leather',
    levelMin: 1,
    levelMax: 3,
    type: ItemType.Armor,
    subType: ArmorType.Leather,
    quality: ItemQuality.Common,
    defense: 10,
    skillType: SkillType.Might,
    skillLevel: 1,
    skillMagicCost: 6,
    regenHealth: 1,
  ),
  Armor_Warrior_1_Leather_Rare(
    label: 'Leather',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Leather,
    quality: ItemQuality.Rare,
    defense: 15,
    regenHealth: 1,
  ),
  Armor_Warrior_1_Leather_Legendary(
    label: 'Leather',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Leather,
    quality: ItemQuality.Legendary,
    defense: 20,
    regenHealth: 2,
  ),
  Armor_Warrior_2_Chainmail_Common(
    label: 'Chainmail',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Chainmail,
    quality: ItemQuality.Common,
    defense: 20,
    regenHealth: 2,
  ),
  Armor_Warrior_2_Chainmail_Rare(
    label: 'Chainmail',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Chainmail,
    quality: ItemQuality.Rare,
    defense: 30,
    regenHealth: 2,
  ),
  Armor_Warrior_2_Chainmail_Legendary(
    label: 'Chainmail',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Chainmail,
    quality: ItemQuality.Legendary,
    defense: 40,
    regenHealth: 3,
  ),
  Armor_Warrior_3_Platemail_Common(
    label: 'Scalemail',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Platemail,
    quality: ItemQuality.Common,
    defense: 30,
    regenHealth: 3,
  ),
  Armor_Warrior_3_Platemail_Rare(
    label: 'Scalemail',
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Armor,
    subType: ArmorType.Platemail,
    quality: ItemQuality.Rare,
    defense: 30,
    regenHealth: 3,
  ),
  Armor_Warrior_3_Platemail_Legendary(
    label: 'Scalemail',
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Armor,
    subType: ArmorType.Platemail,
    quality: ItemQuality.Legendary,
    defense: 30,
    regenHealth: 3,
  ),
  Armor_Wizard_1_Robe_Common(
    label: 'Robe',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Robes,
    quality: ItemQuality.Common,
    defense: 5,
    regenMagic: 1,
    magic: 5,
  ),
  Armor_Wizard_1_Robe_Rare(
    label: 'Robe',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Robes,
    quality: ItemQuality.Rare,
    defense: 8,
    magic: 10,
  ),
  Armor_Wizard_1_Robe_Legendary(
    label: 'Robe',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Robes,
    quality: ItemQuality.Legendary,
    defense: 10,
    magic: 15,
  ),
  Armor_Rogue_1_Cloak_Common(
    label: 'Cloak',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Common,
    defense: 7,
  ),
  Armor_Rogue_1_Cloak_Rare(
    label: 'Cloak',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Rare,
    defense: 9,
  ),
  Armor_Rogue_1_Cloak_Legendary(
    label: 'Cloak',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Legendary,
    defense: 12,
  ),
  Armor_Rogue_2_Mantle_Common(
    label: 'Mantle',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Mantle,
    quality: ItemQuality.Common,
    defense: 9,
  ),
  Armor_Rogue_2_Mantle_Rare(
    label: 'Mantle',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Mantle,
    quality: ItemQuality.Rare,
    defense: 9,
  ),
  Armor_Rogue_2_Mantle_Legendary(
    label: 'Mantle',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Mantle,
    quality: ItemQuality.Legendary,
    defense: 9,
  ),
  Armor_Rogue_3_Shroud_Common(
    label: 'Shroud',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Shroud,
    quality: ItemQuality.Common,
    defense: 9,
  ),
  Armor_Rogue_3_Shroud_Rare(
    label: 'Shroud',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Shroud,
    quality: ItemQuality.Rare,
    defense: 9,
  ),
  Armor_Rogue_3_Shroud_Legendary(
    label: 'Shroud',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Shroud,
    quality: ItemQuality.Legendary,
    defense: 9,
  ),
  Shoes_Warrior_1_Boots_Common(
    label: 'Boots',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Boots,
    performDuration: 25,
    quality: ItemQuality.Common,
    defense: 5,
    runSpeed: -0.125,
  ),
  Shoes_Wizard_1_Slippers_Common(
    label: 'Slippers',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Slippers,
    quality: ItemQuality.Common,
    defense: 1,
    magic: 5,
    skillType: SkillType.Teleport,
    skillLevel: 1,
    skillMagicCost: 6,
  ),
  Shoes_Rogue_1_Treads_Common(
    label: 'Treads',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Treads,
    quality: ItemQuality.Common,
    defense: 1,
    magic: 5,
    skillType: SkillType.Teleport,
    skillLevel: 1,
    skillMagicCost: 6,
  ),
  Shoes_Warrior_2_Grieves_Common(
    label: 'Grieves',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Grieves,
    performDuration: 25,
    quality: ItemQuality.Common,
    defense: 5,
    runSpeed: -0.125,
  ),
  Shoes_Wizard_2_Footwraps_Common(
    label: 'Footwraps',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Footwraps,
    quality: ItemQuality.Common,
    defense: 1,
    magic: 5,
    skillType: SkillType.Teleport,
    skillLevel: 1,
    skillMagicCost: 6,
  ),
  Shoes_Rogue_2_Striders_Common(
    label: 'Striders',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Striders,
    quality: ItemQuality.Common,
    defense: 1,
    magic: 5,
    skillType: SkillType.Teleport,
    skillLevel: 1,
    skillMagicCost: 6,
  ),
  Shoes_Warrior_3_Sabatons_Common(
    label: 'Sabatons',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Sabatons,
    performDuration: 25,
    quality: ItemQuality.Common,
    defense: 5,
    runSpeed: -0.125,
  ),
  Shoes_Wizard_3_Soles_Common(
    label: 'Soles',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Soles,
    quality: ItemQuality.Common,
    defense: 1,
    magic: 5,
    skillType: SkillType.Teleport,
    skillLevel: 1,
    skillMagicCost: 6,
  ),
  Shoes_Rogue_3_Satin_Boots_Common(
    label: 'Satin_Boots',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Satin_Boots,
    quality: ItemQuality.Common,
    defense: 1,
    magic: 5,
    skillType: SkillType.Teleport,
    skillLevel: 1,
    skillMagicCost: 6,
  ),
  Consumable_Potion_Magic(
    label: 'a common tonic',
    description: 'heals a small amount of health',
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Blue,
    levelMin: 0,
    levelMax: 99,
    quality: ItemQuality.Common,
    magic: 20,
  ),
  Consumable_Potion_Health(
    label: 'a common tonic',
    description: 'heals a small amount of health',
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Red,
    levelMin: 0,
    levelMax: 99,
    quality: ItemQuality.Common,
    health: 20,
  );

  /// the minimum level of a fiend that can drop this item
  final int levelMin;
  /// the maximum level of fiends that can drop this item
  final int levelMax;
  final String? description;
  /// this is used by spells which required certain weapons to be equipped
  /// for example split arrow depends on a bow
  final int? dependency;
  /// see item_type.dart in commons
  final int type;
  final int subType;
  final SkillType? skillType;
  final int? skillLevel;
  final int? damageMin;
  final int? damageMax;
  final double? range;
  final double? radius;
  final int? cooldown;
  final int? charges;
  final int? performDuration;
  final int? health;
  final ItemQuality quality;
  final String label;
  final int defense;
  final int? magic;
  final int? regenMagic;
  final int? regenHealth;
  final int? skillMagicCost;
  final double? runSpeed;

  const AmuletItem({
    required this.type,
    required this.subType,
    required this.levelMin,
    required this.levelMax,
    required this.quality,
    required this.label,
    this.defense = 0,
    this.magic,
    this.regenMagic,
    this.regenHealth,
    this.description,
    this.dependency,
    this.skillType,
    this.skillLevel,
    this.damageMin,
    this.damageMax,
    this.range,
    this.radius,
    this.cooldown,
    this.charges,
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

enum SkillType {
  // Warrior
    // Offensive
  Strike(casteType: CasteType.Self),
  Sweep(casteType: CasteType.Self),
  Might(casteType: CasteType.Instant),
    // Defensive
  Terrify(casteType: CasteType.Instant),
  // Wizard
    // Offensive
  Fireball(casteType: CasteType.Directional),
  Explode(casteType: CasteType.Positional),
  Firestorm(casteType: CasteType.Directional),
    // Defensive
  Freeze_Target(casteType: CasteType.Targeted_Enemy),
  Freeze_Area(casteType: CasteType.Positional),
  Heal(casteType: CasteType.Self),
  Teleport(casteType: CasteType.Positional),
  // Rogue
    // Offensive
  Arrow(casteType: CasteType.Self),
    // Defensive
  Invisible(casteType: CasteType.Instant);

  final CasteType casteType;

  const SkillType({
    required this.casteType,
  });

}

enum CasteType {
  Passive,
  Instant,
  Self,
  Positional,
  Targeted_Enemy,
  Targeted_Ally,
  Directional,
}

enum ItemQuality {
  Legendary,
  Rare,
  Common,
}
