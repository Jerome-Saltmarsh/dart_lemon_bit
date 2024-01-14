import '../../src.dart';
import 'package:collection/collection.dart';

enum AmuletItem {
  Weapon_Rusty_Short_Sword(
    levelMin: 1,
    levelMax: 3,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    skillType: SkillType.Strike,
    description: 'A low quality short sword',
    damageMin: 0,
    damageMax: 3,
    range: 40,
    performDuration: 25,
    quality: ItemQuality.Common,
  ),
  Weapon_Short_Sword(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    skillType: SkillType.Strike,
    description: 'A simple short sword',
    performDuration: 25,
    damageMin: 0,
    damageMax: 3,
    range: 40,
    quality: ItemQuality.Common,
  ),
  Weapon_Short_Sword_Of_Pain(
    levelMin: 2,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    skillType: SkillType.Strike,
    description: 'A particularly sharp short sword',
    performDuration: 25,
    range: 40,
    damageMin: 2,
    damageMax: 5,
    quality: ItemQuality.Rare,
  ),
  Weapon_Broad_Sword(
    levelMin: 4,
    levelMax: 10,
    type: ItemType.Weapon,
    subType: WeaponType.Broadsword,
    skillType: SkillType.Strike,
    description: 'A medium length sword',
    performDuration: 35,
    range: 40,
    damageMin: 2,
    damageMax: 5,
    quality: ItemQuality.Common,
  ),
  Weapon_Sword_Sapphire_Large(
    levelMin: 8,
    levelMax: 12,
    type: ItemType.Weapon,
    subType: WeaponType.Sword_Heavy_Sapphire,
    skillType: SkillType.Strike,
    description: 'A powerful heavy sword made of sapphire',
    performDuration: 35,
    range: 40,
    damageMin: 2,
    damageMax: 5,
    quality: ItemQuality.Rare,
  ),
  Weapon_Sharpened_Broad_Sword(
    levelMin: 4,
    levelMax: 10,
    type: ItemType.Weapon,
    subType: WeaponType.Broadsword,
    skillType: SkillType.Strike,
    description: 'A high quality medium length sword',
    performDuration: 35,
    range: 40,
    damageMin: 2,
    damageMax: 5,
    quality: ItemQuality.Rare,
  ),
  Weapon_Staff_Wooden(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Fireball,
    description: 'An old gnarled staff',
    performDuration: 35,
    range: 40,
    damageMin: 2,
    damageMax: 5,
    quality: ItemQuality.Common,
  ),
  Weapon_Old_Bow(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Arrow,
    description: 'A worn out bow',
    performDuration: 25,
    range: 100,
    damageMin: 2,
    damageMax: 5,
    quality: ItemQuality.Common,
  ),
  Weapon_Bow_Composite(
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Arrow,
    description: 'A decently powerful bow with medium range',
    performDuration: 25,
    range: 80,
    damageMin: 2,
    damageMax: 5,
    quality: ItemQuality.Common,
  ),
  Weapon_Holy_Bow(
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Arrow,
    description: 'A mythical bow which does a lot of damage',
    performDuration: 25,
    range: 120,
    damageMin: 20,
    damageMax: 25,
    quality: ItemQuality.Legendary,
  ),
  Helm_Steel(
    levelMin: 5,
    levelMax: 10,
    skillType: SkillType.Heal,
    description: 'A strong steel helmet which provides healing.',
    type: ItemType.Helm,
    subType: HelmType.Steel,
    performDuration: 25,
    health: 6,
    quality: ItemQuality.Common,
  ),
  Helm_Wizards_Hat(
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Freeze_Area,
    type: ItemType.Helm,
    subType: HelmType.Wizard_Hat,
    description: 'A hat commonly worn by students of magic school',
    performDuration: 25,
    health: 2,
    quality: ItemQuality.Common,
  ),
  Helm_Moth_Hat_Of_Magic(
    levelMin: 5,
    levelMax: 10,
    skillType: SkillType.Fireball,
    type: ItemType.Helm,
    subType: HelmType.Witches_Hat,
    description: 'an old moth eaten hat that emanates magic',
    performDuration: 25,
    range: 200,
    damageMin: 5,
    damageMax: 5,
    quality: ItemQuality.Rare,
  ),
  Helm_Hunters_Cap_Of_The_Moon(
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Helm,
    subType: HelmType.Steel,
    description: 'an incredibly rare and powerful hat useful for hunting',
    performDuration: 25,
    quality: ItemQuality.Legendary,
  ),
  Boots_Black_Boots_Of_Magic(
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Shoes,
    subType: ShoeType.Black_Boots,
    description: 'reduces all cooldowns',
    performDuration: 25,
    quality: ItemQuality.Rare,
  ),
  Armor_Shirt_Blue_Worn(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Shirt_Blue,
    description: 'An ordinary shirt',
    performDuration: 25,
    quality: ItemQuality.Common,
  ),
  Armor_Black_Cloak(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Black_Cloak,
    description: 'A cloak that enhances magical ability',
    performDuration: 25,
    quality: ItemQuality.Common,
  ),
  Armor_Leather_Basic(
    levelMin: 3,
    levelMax: 6,
    type: ItemType.Body,
    subType: BodyType.Leather_Armour,
    description: 'Common armour',
    performDuration: 25,
    quality: ItemQuality.Common,
  ),
  Shoe_Leather_Boots(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    description: 'A common leather boots',
    performDuration: 25,
    quality: ItemQuality.Common,
  ),
  Shoe_Iron_Plates(
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    description: 'Heavy boots which provide good defense',
    performDuration: 25,
    quality: ItemQuality.Common,
  ),
  Potion_Health(
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Red,
    description: 'heals a small amount of health',
    levelMin: 0,
    levelMax: 99,
    quality: ItemQuality.Common,
  );

  /// the minimum level of a fiend that can drop this item
  final int levelMin;
  /// the maximum level of fiends that can drop this item
  final int levelMax;
  final String description;
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

  const AmuletItem({
    required this.type,
    required this.subType,
    required this.description,
    required this.levelMin,
    required this.levelMax,
    required this.quality,
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

  bool get isWeaponStaff => isWeapon && subType == WeaponType.Staff;

  bool get isWeaponSword => isWeapon && subType == WeaponType.Shortsword;

  bool get isWeaponBow => isWeapon && subType == WeaponType.Bow;

  bool get isWeapon => type == ItemType.Weapon;

  bool get isSpell => type == ItemType.Spell;

  bool get isShoes => type == ItemType.Shoes;

  bool get isHelm => type == ItemType.Helm;

  bool get isHand => type == ItemType.Hand;

  bool get isConsumable => type == ItemType.Consumable;

  bool get isBody => type == ItemType.Body;

  bool get isLegs => type == ItemType.Legs;

  bool get isTreasure => type == ItemType.Treasure;

  static final typeBodies =
      values.where((element) => element.isBody).toList(growable: false);

  static final typeHelms =
      values.where((element) => element.isHelm).toList(growable: false);

  static final typeShoes =
      values.where((element) => element.isShoes).toList(growable: false);

  static final typeWeapons =
      values.where((element) => element.isWeapon).toList(growable: false);

  static final typeHands =
      values.where((element) => element.isHand).toList(growable: false);

  static final typeLegs =
      values.where((element) => element.isLegs).toList(growable: false);

  static final typeConsumables =
      values.where((element) => element.isConsumable).toList(growable: false);

  static AmuletItem? getBody(int type) =>
      typeBodies.firstWhereOrNull((element) => element.subType == type);

  static AmuletItem? getShoe(int type) =>
      typeShoes.firstWhereOrNull((element) => element.subType == type);

  static AmuletItem? getWeapon(int type) =>
      typeWeapons.firstWhereOrNull((element) => element.subType == type);

  static AmuletItem? findByName(String name) =>
      values.firstWhereOrNull((element) => element.name == name);

  static AmuletItem? getHand(int type) =>
      typeHands.firstWhereOrNull((element) => element.subType == type);

  static AmuletItem? getHelm(int type) =>
      typeHelms.firstWhereOrNull((element) => element.subType == type);

  static AmuletItem? getLegs(int type) =>
      typeLegs.firstWhereOrNull((element) => element.subType == type);

  static AmuletItem get({
    required int type,
    required int subType,
  }) =>
      values.firstWhere(
          (element) => element.type == type && element.subType == subType);
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
