import '../../src.dart';
import 'package:collection/collection.dart';

// armour
  // warrior
    // tunic
    // leather
    // chainmail
    // platemail
 // wizard
    // robes
    // garb
 // rogue
    // hood
    // cloak


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
    performDuration: 35,
    range: 50,
    damageMin: 3,
    damageMax: 7,
    quality: ItemQuality.Rare,
  ),
  Weapon_Bow_1_5_Common(
    label: 'Wooden Short Bow',
    description: 'A worn out bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Arrow,
    performDuration: 25,
    range: 100,
    damageMin: 2,
    damageMax: 5,
    quality: ItemQuality.Common,
  ),
  Weapon_Bow_1_5_Rare(
    label: 'Rangers Bow',
    description: 'This bow was crafted from a stronger wood',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Arrow,
    performDuration: 25,
    range: 120,
    damageMin: 3,
    damageMax: 8,
    quality: ItemQuality.Rare,
  ),
  Weapon_Bow_1_5_Legendary(
    label: 'Hollow Bow',
    description: 'A mythical item lost hundreds of years ago',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Arrow,
    performDuration: 32,
    range: 120,
    damageMin: 5,
    damageMax: 10,
    quality: ItemQuality.Legendary,
  ),
  Helm_Warrior_1_5_Common(
    label: 'Steel Helm',
    description: 'A strong steel helmet which provides healing.',
    levelMin: 5,
    levelMax: 10,
    skillType: SkillType.Heal,
    type: ItemType.Helm,
    subType: HelmType.Steel,
    performDuration: 25,
    health: 6,
    quality: ItemQuality.Common,
  ),
  Helm_Wizard_1_5_Common(
    label: 'Steel Helm',
    description: 'A strong steel helmet which provides healing.',
    levelMin: 5,
    levelMax: 10,
    skillType: SkillType.Heal,
    type: ItemType.Helm,
    subType: HelmType.Steel,
    performDuration: 25,
    health: 6,
    quality: ItemQuality.Common,
  ),
  Helm_Rogue_1_5_Common(
    label: 'Steel Helm',
    description: 'A strong steel helmet which provides healing.',
    levelMin: 5,
    levelMax: 10,
    skillType: SkillType.Heal,
    type: ItemType.Helm,
    subType: HelmType.Steel,
    performDuration: 25,
    health: 6,
    quality: ItemQuality.Common,
  ),
  Armor_Warrior_1_5_Common(
    label: 'Common Tunic',
    description: 'An ordinary shirt',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Tunic,
    quality: ItemQuality.Common,
  ),
  Armor_Warrior_1_5_Rare(
    label: 'Rare Tunic',
    description: 'A well crafted tunic',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Tunic,
    quality: ItemQuality.Rare,
  ),
  Armor_Warrior_1_5_Legendary(
    label: 'Legendary Tunic',
    description: 'a very expensive tunic',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Shirt_Blue,
    quality: ItemQuality.Legendary,
  ),
  Armor_Wizard_1_5_Common(
    label: 'Robes',
    description: 'An ordinary shirt',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Tunic,
    quality: ItemQuality.Common,
  ),
  Armor_Wizard_1_5_Rare(
    label: 'Rare Robes',
    description: 'A well crafted tunic',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Tunic,
    quality: ItemQuality.Rare,
  ),
  Armor_Wizard_1_5_Legendary(
    label: 'Legendary Robes',
    description: 'a very expensive tunic',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Shirt_Blue,
    quality: ItemQuality.Legendary,
  ),
  Armor_Neutral_1_5_Common(
    label: 'Shirt',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Shirt_Blue,
    quality: ItemQuality.Common,
  ),
  Armor_Rogue_1_5_Common(
    label: 'Robes',
    description: 'An ordinary shirt',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Tunic,
    quality: ItemQuality.Common,
  ),
  Armor_Rogue_1_5_Rare(
    label: 'Rare Robes',
    description: 'A well crafted tunic',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Tunic,
    quality: ItemQuality.Rare,
  ),
  Armor_Rogue_1_5_Legendary(
    label: 'Legendary Robes',
    description: 'a very expensive tunic',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Shirt_Blue,
    quality: ItemQuality.Legendary,
  ),
  Shoes_Warrior_1_5_Common(
    label: 'Leather Boots',
    description: 'made of common leather',
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    performDuration: 25,
    quality: ItemQuality.Rare,
  ),
  Shoes_Wizard_1_5_Common(
    label: 'Leather Boots',
    description: 'made of common leather',
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    performDuration: 25,
    quality: ItemQuality.Rare,
  ),
  Shoes_Rogue_1_5_Common(
    label: 'Leather Boots',
    description: 'made of common leather',
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    performDuration: 25,
    quality: ItemQuality.Rare,
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

  const AmuletItem({
    required this.type,
    required this.subType,
    required this.levelMin,
    required this.levelMax,
    required this.quality,
    required this.label,
    this.description,
    this.dependency,
    this.skillType,
    this.damageMin,
    this.damageMax,
    this.range,
    this.radius,
    this.cooldown,
    this.charges,
    this.performDuration,
    this.health,
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
  Strike(casteType: CasteType.Self),
  Arrow(casteType: CasteType.Self),
  Heal(casteType: CasteType.Self),
  Fireball(casteType: CasteType.Directional),
  Explode(casteType: CasteType.Positional),
  Firestorm(casteType: CasteType.Directional),
  Teleport(casteType: CasteType.Positional),
  Freeze_Target(casteType: CasteType.Targeted_Enemy),
  Freeze_Area(casteType: CasteType.Positional),
  Invisible(casteType: CasteType.Instant),
  Terrify(casteType: CasteType.Instant);

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
