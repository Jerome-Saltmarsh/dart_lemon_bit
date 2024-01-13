import '../../src.dart';


enum AmuletItem {
  Weapon_Rusty_Short_Sword(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    description: 'A low quality short sword',
    damageMin: 0,
    damageMax: 3,
    range: 40,
    performDuration: 25,
  ),
  Weapon_Short_Sword(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    description: 'A simple short sword',
    performDuration: 25,
    damageMin: 0,
    damageMax: 3,
    range: 40,
  ),
  Weapon_Short_Sword_Of_Pain(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    description: 'A particularly sharp short sword',
    performDuration: 25,
    range: 40,
    damageMin: 2,
    damageMax: 5,
  ),
  Weapon_Broad_Sword(
    levelMin: 4,
    levelMax: 10,
    type: ItemType.Weapon,
    subType: WeaponType.Broadsword,
    description: 'A medium length sword',
    performDuration: 35,
    range: 40,
    damageMin: 2,
    damageMax: 5,
  ),
  Weapon_Sword_Sapphire_Large(
    levelMin: 8,
    levelMax: 12,
    type: ItemType.Weapon,
    subType: WeaponType.Sword_Heavy_Sapphire,
    description: 'A powerful heavy sword made of sapphire',
    performDuration: 35,
    range: 40,
    damageMin: 2,
    damageMax: 5,
  ),
  Weapon_Sharpened_Broad_Sword(
    levelMin: 4,
    levelMax: 10,
    type: ItemType.Weapon,
    subType: WeaponType.Broadsword,
    description: 'A high quality medium length sword',
    performDuration: 35,
    range: 40,
    damageMin: 2,
    damageMax: 5,
  ),
  Weapon_Staff_Wooden(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    description: 'An old gnarled staff',
    performDuration: 35,
    range: 40,
    damageMin: 2,
    damageMax: 5,
  ),
  Weapon_Old_Bow(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    description: 'A worn out bow',
    performDuration: 25,
    range: 40,
    damageMin: 2,
    damageMax: 5,
  ),
  Weapon_Holy_Bow(
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    description: 'A mythical bow which does a lot of damage',
    performDuration: 25,
    range: 40,
    damageMin: 2,
    damageMax: 5,
  ),
  Helm_Steel(
    levelMin: 5,
    levelMax: 10,
    skillType: SkillType.Heal,
    description: 'A strong steel helmet which provides healing.',
    type: ItemType.Helm,
    subType: HelmType.Steel,
    performDuration: 25,
  ),
  Helm_Wizards_Hat(
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Freeze_Area,
    type: ItemType.Helm,
    subType: HelmType.Wizard_Hat,
    description: 'A hat commonly worn by students of magic school',
    performDuration: 25,
  ),
  Moth_Hat_Of_Magic(
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
  ),
  Pants_Travellers(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Legs,
    subType: LegType.Leather,
    description: 'Common pants made for more for comfort than combat',
    performDuration: 25,
  ),
  Pants_Squires(
    levelMin: 3,
    levelMax: 8,
    type: ItemType.Legs,
    subType: LegType.Leather,
    description: 'increases attack speed with bows',
    performDuration: 25,
  ),
  Pants_Plated(
    levelMin: 10,
    levelMax: 15,
    type: ItemType.Legs,
    subType: LegType.Plated,
    description: 'Quite heavy but they offer a lot of protection',
    performDuration: 25,
  ),
  Pants_Linen_Striped(
    levelMin: 10,
    levelMax: 15,
    type: ItemType.Legs,
    subType: LegType.Linen_Striped,
    description: 'Light weight pants for for mobility',
    performDuration: 25,
  ),
  Black_Boots_Of_Magic(
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Shoes,
    subType: ShoeType.Black_Boots,
    description: 'reduces all cooldowns',
    performDuration: 25,
  ),
  Gauntlet_of_the_Knight(
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Hand,
    subType: HandType.Gauntlets,
    description: 'passively increases melee damage',
    performDuration: 25,
  ),
  Glove_Healers_Hand(
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Hand,
    subType: HandType.Leather_Gloves,
    description: 'heals the player a small amount',
    performDuration: 25,
  ),
  Leather_Gloves(
    levelMin: 1,
    levelMax: 8,
    type: ItemType.Hand,
    subType: HandType.Leather_Gloves,
    description: 'Common leather gloves',
    performDuration: 25,
  ),
  Armor_Shirt_Blue_Worn(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Shirt_Blue,
    description: 'An ordinary shirt',
    performDuration: 25,
  ),
  Armor_Black_Cloak(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Body,
    subType: BodyType.Black_Cloak,
    description: 'A cloak that enhances magical ability',
    performDuration: 25,
  ),
  Armor_Leather_Basic(
    levelMin: 3,
    levelMax: 6,
    type: ItemType.Body,
    subType: BodyType.Leather_Armour,
    description: 'Common armour',
    performDuration: 25,
  ),
  Shoe_Leather_Boots(
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    description: 'A common leather boots',
    performDuration: 25,
  ),
  Shoe_Iron_Plates(
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    description: 'Heavy boots which provide good defense',
    performDuration: 25,
  ),
  Potion_Health(
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Red,
    description: 'heals a small amount of health',
    levelMin: 0,
    levelMax: 99,
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
  final int? cooldown;
  final int? charges;
  final int? performDuration;

  const AmuletItem({
    required this.type,
    required this.subType,
    required this.description,
    required this.levelMin,
    required this.levelMax,
    this.dependency,
    this.skillType,
    this.damageMin,
    this.damageMax,
    this.range,
    this.cooldown,
    this.charges,
    this.performDuration,
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

  static AmuletItem getBody(int type) =>
      typeBodies.firstWhere((element) => element.subType == type);

  static AmuletItem getShoe(int type) =>
      typeShoes.firstWhere((element) => element.subType == type);

  static AmuletItem getWeapon(int type) =>
      typeWeapons.firstWhere((element) => element.subType == type);

  static AmuletItem? findByName(String name) {
    if (name != '-') {
      for (final value in values) {
        if (value.name == name) {
          return value;
        }
      }
    }
    return null;
  }

  static AmuletItem getHand(int type) =>
      typeHands.firstWhere((element) => element.subType == type);

  static AmuletItem getHelm(int type) =>
      typeHelms.firstWhere((element) => element.subType == type);

  static AmuletItem getLegs(int type) =>
      typeLegs.firstWhere((element) => element.subType == type);

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
  Fireball(casteType: CasteType.Targeted_Enemy, range: 150),
  Explode(casteType: CasteType.Positional, range: 150),
  Firestorm(casteType: CasteType.Directional),
  Teleport(casteType: CasteType.Positional, range: 200),
  Freeze_Target(casteType: CasteType.Targeted_Enemy, range: 180),
  Freeze_Area(casteType: CasteType.Positional, range: 180, radius: 50),
  Invisible(casteType: CasteType.Instant),
  Terrify(casteType: CasteType.Instant, radius: 100);

  final CasteType casteType;
  final double? range;
  final double? radius;

  const SkillType({
    required this.casteType,
    this.range,
    this.radius,
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

