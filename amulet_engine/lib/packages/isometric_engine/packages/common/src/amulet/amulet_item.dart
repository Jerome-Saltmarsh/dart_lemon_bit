import '../../src.dart';
import 'package:collection/collection.dart';

// armour
  // warrior
    // tunic
    // leather
    // scale
    // splint
    // banded
    // chainmail
    // platemail
    // brigandine
 // wizard
    // cowl
    // robes
    // garb
    // attire
 // rogue
    // cloak
    // mantle
    // shroud

// helm
  // warrior
    // leather cap
    // steel helm
    // great helm
  // wizard
    // pointed hat
    // circlet
    // crest
    // diadem
    // turban
  // rogue
    // hood
    // cape
    // veil

// shoes
  // warrior
    // boots
    // grieves
    // sabatons
  // wizard
    // slippers
    // striders
    // soles
  // rogue
    // treads
    // footwraps
    // shoes

enum AmuletItem {
  Weapon_Sword_1_5_Common(
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
  Weapon_Sword_1_5_Rare(
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
  Weapon_Sword_1_5_Legendary(
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
  Weapon_Staff_1_5_Common(
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
  Weapon_Staff_1_5_Rare(
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
  Weapon_Staff_1_5_Legendary(
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
  Weapon_Bow_1_5_Common(
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
  Weapon_Bow_1_5_Rare(
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
  Weapon_Bow_1_5_Legendary(
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
  Helm_Warrior_1_5_Common(
    label: 'Common Helm',
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
  Helm_Wizard_1_5_Common(
    label: 'Common Pointed Hat',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Heal,
    type: ItemType.Helm,
    subType: HelmType.Pointed_Hat,
    performDuration: 25,
    defense: 2,
    quality: ItemQuality.Common,
    regenMagic: 1,
    skillMagicCost: 3,
  ),
  Helm_Rogue_1_5_Common(
    label: 'Steel Helm',
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
  Armor_Neutral_1_5_Common(
    label: 'Shirt',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Shirt_Blue,
    quality: ItemQuality.Common,
    defense: 1,
  ),
  Armor_Warrior_1_5_Common(
    label: 'Common Tunic',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Tunic,
    quality: ItemQuality.Common,
    defense: 10,
    skillType: SkillType.Might,
    skillLevel: 1,
    skillMagicCost: 6,
    regenHealth: 1,
  ),
  Armor_Warrior_1_5_Rare(
    label: 'Rare Tunic',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Tunic,
    quality: ItemQuality.Rare,
    defense: 15,
  ),
  Armor_Warrior_1_5_Legendary(
    label: 'Legendary Tunic',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Tunic,
    quality: ItemQuality.Legendary,
    defense: 20,
  ),
  Armor_Wizard_1_5_Common(
    label: 'Common Cowl',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Cowl,
    quality: ItemQuality.Common,
    defense: 5,
    regenMagic: 1,
    magic: 5,
  ),
  Armor_Wizard_1_5_Rare(
    label: 'Rare Cowl',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Cowl,
    quality: ItemQuality.Rare,
    defense: 8,
    magic: 10,
  ),
  Armor_Wizard_1_5_Legendary(
    label: 'Legendary Cowl',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Cowl,
    quality: ItemQuality.Legendary,
    defense: 10,
    magic: 15,
  ),
  Armor_Rogue_1_5_Common(
    label: 'Common Cloak',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Cloak,
    quality: ItemQuality.Common,
    defense: 7,
  ),
  Armor_Rogue_1_5_Rare(
    label: 'Rare Cloak',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Cloak,
    quality: ItemQuality.Rare,
    defense: 9,
  ),
  Armor_Rogue_1_5_Legendary(
    label: 'Legendary Cloak',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Cloak,
    quality: ItemQuality.Legendary,
    defense: 12,
  ),
  Shoes_Warrior_1_5_Common(
    label: 'Common Leather Boots',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    performDuration: 25,
    quality: ItemQuality.Common,
    defense: 5,
    runSpeed: -0.125,
  ),
  Shoes_Wizard_1_5_Common(
    label: 'Common Silk Boots',
    description: 'made of common leather',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    quality: ItemQuality.Common,
    defense: 1,
    magic: 5,
    skillType: SkillType.Teleport,
    skillLevel: 1,
    skillMagicCost: 6,
  ),
  Shoes_Rogue_1_5_Common(
    label: 'Leather Boots',
    description: 'made of common leather',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    performDuration: 25,
    quality: ItemQuality.Common,
    defense: 2,
    runSpeed: 0.125,
  ),
  Consumable_Potion_Health(
    label: 'a common tonic',
    description: 'heals a small amount of health',
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Red,
    levelMin: 0,
    levelMax: 99,
    quality: ItemQuality.Common,
  );

  /// the minimum level of a fiend that can drop this item
  final int levelMin;
  /// the maximum level of fiends that can drop this item
  final int levelMax;
  final String? description;
  /// this is used by spells which required certain weapons to be equipped
  /// for example split arrow depends on a bow
  final int? dependency;
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

  bool get isHand => type == ItemType.Hand;

  bool get isConsumable => type == ItemType.Consumable;

  bool get isBody => type == ItemType.Body;

  bool get isLegs => type == ItemType.Legs;

  static AmuletItem? findByName(String name) =>
      values.firstWhereOrNull((element) => element.name == name);
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
