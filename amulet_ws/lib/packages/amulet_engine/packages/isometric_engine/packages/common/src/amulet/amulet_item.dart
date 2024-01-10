import '../../src.dart';

// common
// magical
// rare

enum AmuletItem {
  Blink_Dagger(
    selectAction: AmuletItemAction.Positional,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    description: 'Teleport a short distance',
    levelMin: 1,
    levelMax: 99,
    level1: AmuletItemStats(
      charges: 1,
      cooldown: 0,
      range: 150,
      performDuration: 16,
    ),
    level2: AmuletItemStats(
      charges: 1,
      cooldown: 0,
      range: 160,
      performDuration: 16,
    ),
    level3: AmuletItemStats(
      charges: 1,
      cooldown: 0,
      range: 170,
      performDuration: 16,
    ),
  ),
  Weapon_Rusty_Short_Sword(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    description: 'A low quality short sword',
    level1: AmuletItemStats(
      damageMin: 1,
      damageMax: 3,
      range: 45,
      cooldown: 1,
      charges: 1,
      performDuration: 32,
    ),
  ),
  Weapon_Short_Sword(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    description: 'A plain short sword',
    level1: AmuletItemStats(
      damageMin: 2,
      damageMax: 4,
      range: 50,
      cooldown: 1,
      charges: 1,
      performDuration: 32,
    ),
  ),
  Weapon_Short_Sword_Of_Pain(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    description: 'A particularly sharp short sword',
    level1: AmuletItemStats(
      damageMin: 3,
      damageMax: 5,
      range: 50,
      cooldown: 1,
      charges: 1,
      performDuration: 32,
    ),
  ),
  Weapon_Rodungs_Blade(
    levelMin: 3,
    levelMax: 5,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    description: 'Are rare blade that once belonged to a great swordsman',
    level1: AmuletItemStats(
      damageMin: 6,
      damageMax: 8,
      range: 50,
      cooldown: 1,
      charges: 1,
      performDuration: 20,
    ),
  ),
  Weapon_Broad_Sword(
    levelMin: 4,
    levelMax: 10,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Weapon,
    subType: WeaponType.Broadsword,
    description: 'A medium length sword',
    level1: AmuletItemStats(
      damageMin: 7,
      damageMax: 10,
      range: 70,
      cooldown: 1,
      charges: 1,
      performDuration: 32,
    ),
    level2: AmuletItemStats(
      damageMin: 9,
      damageMax: 12,
      range: 70,
      cooldown: 4,
      charges: 7,
      performDuration: 28,
      fire: 1,
    ),
    level3: AmuletItemStats(
      damageMin: 11,
      damageMax: 14,
      range: 70,
      cooldown: 4,
      charges: 7,
      performDuration: 26,
      fire: 3,
    ),
  ),
  Weapon_Sword_Sapphire_Large(
    levelMin: 8,
    levelMax: 12,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Weapon,
    subType: WeaponType.Sword_Heavy_Sapphire,
    description: 'A powerful heavy sword made of sapphire',
    level1: AmuletItemStats(
      damageMin: 12,
      damageMax: 20,
      range: 100,
      cooldown: 1,
      charges: 1,
      performDuration: 40,
    ),
  ),
  Weapon_Sharpened_Broad_Sword(
    levelMin: 4,
    levelMax: 10,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Weapon,
    subType: WeaponType.Broadsword,
    description: 'A high quality medium length sword',
    level1: AmuletItemStats(
      damageMin: 8,
      damageMax: 12,
      range: 70,
      cooldown: 1,
      charges: 1,
      performDuration: 30,
    ),
    level2: AmuletItemStats(
      damageMin: 9,
      damageMax: 12,
      range: 70,
      cooldown: 4,
      charges: 7,
      performDuration: 28,
      fire: 1,
    ),
    level3: AmuletItemStats(
      damageMin: 11,
      damageMax: 14,
      range: 70,
      cooldown: 4,
      charges: 7,
      performDuration: 26,
      fire: 3,
    ),
  ),
  Weapon_Staff_Wooden(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    description: 'An old gnarled staff',
    level1: AmuletItemStats(
        range: 200,
        damageMin: 1,
        damageMax: 3,
        cooldown: 1,
        performDuration: 25,
        charges: 1,
    ),
  ),
  Weapon_Staff_Of_Frozen_Lake(
    levelMin: 5,
    levelMax: 10,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    description: 'A powerful staff that eliminates cold',
    level1: AmuletItemStats(
        range: 100,
        damageMin: 1,
    ),
  ),
  Spell_Bow_Ice_Arrow(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Targeted_Enemy,
    dependency: WeaponType.Bow,
    type: ItemType.Spell,
    subType: SpellType.Split_Arrow,
    description: 'fires multiple arrows',
    level1: AmuletItemStats(
      damageMin: 3,
      damageMax: 6,
      fire: 0,
      charges: 3,
      cooldown: 30,
      performDuration: 25,
      quantity: 3,
    ),
  ),
  Spell_Bow_Split_Arrow(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Directional,
    dependency: WeaponType.Bow,
    type: ItemType.Spell,
    subType: SpellType.Split_Arrow,
    description: 'fires multiple arrows',
    level1: AmuletItemStats(
      damageMin: 3,
      damageMax: 6,
      fire: 0,
      charges: 3,
      cooldown: 30,
      performDuration: 25,
      quantity: 3,
    ),
    level2: AmuletItemStats(
      damageMin: 6,
      damageMax: 9,
      fire: 3,
      water: 2,
      electricity: 1,
      charges: 3,
      cooldown: 30,
      performDuration: 25,
      quantity: 4,
    ),
    level3: AmuletItemStats(
      damageMin: 9,
      damageMax: 12,
      fire: 3,
      water: 2,
      electricity: 1,
      charges: 3,
      cooldown: 30,
      performDuration: 25,
      quantity: 4,
    ),
  ),
  Weapon_Old_Bow(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    description: 'A worn out bow',
    level1: AmuletItemStats(
      damageMin: 2,
      damageMax: 3,
      charges: 3,
      cooldown: 8,
      range: 150,
      performDuration: 20,
      electricity: 0,
    ),
    level2: AmuletItemStats(
      damageMin: 7,
      damageMax: 12,
      charges: 3,
      cooldown: 9,
      range: 160,
      performDuration: 18,
      electricity: 2,
    ),
    level3: AmuletItemStats(
      damageMin: 9,
      damageMax: 14,
      charges: 4,
      cooldown: 9,
      range: 160,
      performDuration: 18,
      electricity: 6,
    ),
  ),
  Weapon_Holy_Bow(
    levelMin: 5,
    levelMax: 10,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    description: 'A mythical bow which does a lot of damage',
    level1: AmuletItemStats(
        range: 150,
        damageMin: 5,
        damageMax: 10,
        cooldown: 15,
        charges: 3,
        performDuration: 15,
    ),
    level2: AmuletItemStats(
      range: 160,
      damageMin: 1,
      damageMax: 15,
      cooldown: 38,
      charges: 5,
      performDuration: 13,
    ),
    level3: AmuletItemStats(
      range: 200,
      damageMin: 22,
      damageMax: 30,
      cooldown: 10,
      charges: 10,
      performDuration: 11,
    ),
  ),
  Helm_Steel(
    levelMin: 5,
    levelMax: 10,
    selectAction: AmuletItemAction.Equip,
    description: 'An ordinary helmet made of steel',
    type: ItemType.Helm,
    subType: HelmType.Steel,
    level1: AmuletItemStats(),
  ),
  Helm_Wizards_Hat(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Helm,
    subType: HelmType.Wizard_Hat,
    description: 'A hat commonly worn by students of magic school',
    level1: AmuletItemStats(),
  ),
  Moth_Hat_Of_Magic(
    levelMin: 5,
    levelMax: 10,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Helm,
    subType: HelmType.Witches_Hat,
    description: 'an old moth eaten hat that emanates magic',
    level1: AmuletItemStats(
      health: 20,
    ),
  ),
  Pants_Travellers(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Legs,
    subType: LegType.Leather,
    description: 'Common pants made for more for comfort than combat',
    level1: AmuletItemStats(
      health: 5,
    ),
  ),
  Pants_Squires(
    levelMin: 3,
    levelMax: 8,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Legs,
    subType: LegType.Leather,
    description: 'light pants which provide easy movement with some protection',
    level1: AmuletItemStats(
      health: 10,
    ),
  ),
  Pants_Plated(
    levelMin: 10,
    levelMax: 15,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Legs,
    subType: LegType.Plated,
    description: 'Quite heavy but they offer a lot of protection',
    level1: AmuletItemStats(
      health: 16,
    ),
  ),
  Pants_Linen_Striped(
    levelMin: 10,
    levelMax: 15,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Legs,
    subType: LegType.Linen_Striped,
    description: 'Light weight pants for for mobility',
    level1: AmuletItemStats(
      health: 16,
    ),
  ),
  Gauntlet(
    levelMin: 5,
    levelMax: 10,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Hand,
    subType: HandType.Gauntlets,
    description: 'Common gauntlets',
    level1: AmuletItemStats(
      health: 5,
    ),
  ),
  Black_Boots_Of_Magic(
    levelMin: 5,
    levelMax: 10,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Shoes,
    subType: ShoeType.Black_Boots,
    description: 'Mystical boots',
    level1: AmuletItemStats(
      health: 5,
    ),
  ),
  Leather_Gloves(
    levelMin: 1,
    levelMax: 8,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Hand,
    subType: HandType.Leather_Gloves,
    description: 'Common leather gloves',
    level1: AmuletItemStats(
      health: 5,
    ),
  ),
  Armor_Shirt_Blue_Worn(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Body,
    subType: BodyType.Shirt_Blue,
    description: 'An ordinary shirt',
    level1: AmuletItemStats(
      health: 10,
    ),
  ),
  Armor_Black_Cloak(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Body,
    subType: BodyType.Black_Cloak,
    description: 'A cloak that enhances magical ability',
    level1: AmuletItemStats(
      health: 10,
    ),
  ),
  Armor_Leather_Basic(
    levelMin: 3,
    levelMax: 6,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Body,
    subType: BodyType.Leather_Armour,
    description: 'Common armour',
    level1: AmuletItemStats(
      health: 15
    ),
  ),
  Shoe_Leather_Boots(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    description: 'A common leather boots',
    level1: AmuletItemStats(
      health: 5,
      electricity: 2,
    ),
    level2: AmuletItemStats(
      health: 10,
      electricity: 4,
    ),
    level3: AmuletItemStats(
      health: 15,
      electricity: 8,
    ),
  ),
  Shoe_Iron_Plates(
    levelMin: 5,
    levelMax: 10,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    description: 'Heavy boots which provide good defense',
    level1: AmuletItemStats(
      health: 5,
      fire: 5
    ),
    level2: AmuletItemStats(
      health: 10,
      fire: 8
    ),
    level3: AmuletItemStats(
      health: 12,
    ),
  ),
  Shoe_Ocean_Boots(
    levelMin: 5,
    levelMax: 10,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    description: 'Commonly worn by water mages',
    level1: AmuletItemStats(),
  ),
  Shoe_Storm_Boots(
    levelMin: 10,
    levelMax: 15,
    selectAction: AmuletItemAction.Equip,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    description: 'commonly worn by electric mages',
    level1: AmuletItemStats(),
  ),
  Potion_Health(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Consume,
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Red,
    consumable: true,
    description: 'Replenishes health',
    level1: AmuletItemStats(
      health: 5,
    ),
  ),
  Treasure_Fury_Pendent(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.None,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    description: 'faster sword attacks',
    level1: AmuletItemStats(

    ),
  ),
  Amulet_Of_The_Ranger(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.None,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    description: 'increases arrow damage',
    level1: AmuletItemStats(

    ),
  ),
  Sapphire_Pendant(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.None,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    description: 'a radian blue pendant',
    level1: AmuletItemStats(),
  ),
  Spell_Thunderbolt(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Caste,
    type: ItemType.Spell,
    subType: SpellType.Thunderbolt,
    description: 'strikes random nearby enemies with lightning',
    level1: AmuletItemStats(
      damageMin: 3,
      damageMax: 5,
      cooldown: 30,
      charges: 2,
      electricity: 0,
      range: 100,
      quantity: 1,
    ),
    level2: AmuletItemStats(
      damageMin: 5,
      damageMax: 10,
      cooldown: 28,
      charges: 2,
      electricity: 3,
      fire: 1,
      range: 150,
    ),
    level3: AmuletItemStats(
      damageMin: 12,
      damageMax: 16,
      cooldown: 26,
      charges: 2,
      electricity: 6,
      fire: 2,
      range: 200,
    ),
  ),
  Spell_Fireball(
    levelMin: 1,
    levelMax: 5,
    selectAction: AmuletItemAction.Caste,
    type: ItemType.Spell,
    subType: SpellType.Fireball,
    description: 'strikes random nearby enemies with lightning',
    level1: AmuletItemStats(
      damageMin: 3,
      damageMax: 5,
      cooldown: 5,
      charges: 2,
      fire: 0,
      range: 100,
      quantity: 1,
      performDuration: 25,
    ),
    level2: AmuletItemStats(
      damageMin: 5,
      damageMax: 10,
      cooldown: 4,
      charges: 2,
      electricity: 3,
      fire: 1,
      range: 150,
      performDuration: 20,
    ),
    level3: AmuletItemStats(
      damageMin: 12,
      damageMax: 16,
      cooldown: 3,
      charges: 2,
      electricity: 6,
      fire: 2,
      range: 200,
      performDuration: 15,
    ),
  ),
  Spell_Blink(
    levelMin: 1,
    levelMax: 5,
      selectAction: AmuletItemAction.Positional,
      type: ItemType.Spell,
      subType: SpellType.Blink,
      description: 'teleport a short distance',
      level1: AmuletItemStats(
        cooldown: 30,
        range: 50,
      ),
      level2: AmuletItemStats(
        cooldown: 28,
        range: 60,
      ),
      level3: AmuletItemStats(
        cooldown: 26,
        range: 70,
      ),
  ),
  Spell_Heal(
    levelMin: 1,
    levelMax: 5,
      selectAction: AmuletItemAction.Caste,
      type: ItemType.Spell,
      subType: SpellType.Heal,
      description: 'heals a small amount of health',
      level1: AmuletItemStats(
        charges: 1,
        cooldown: 14,
        health: 5,
        performDuration: 25,
        water: 0,
      ),
      level2: AmuletItemStats(
        charges: 1,
        cooldown: 12,
        health: 7,
        performDuration: 23,
        water: 3,
      ),
      level3: AmuletItemStats(
        charges: 1,
        cooldown: 10,
        health: 10,
        performDuration: 21,
        water: 6,
        electricity: 1,
      ),
  );

  /// the minimum level of a fiend that can drop this item
  final int levelMin;
  /// the maximum level of fiends that can drop this item
  final int levelMax;
  final String description;
  /// this is used by spells which required certain weapons to be equipped
  /// for example split arrow depends on a bow
  final int? dependency;
  final AmuletItemAction selectAction;
  final int type;
  final int subType;
  final bool consumable;
  final AmuletItemStats level1;
  final AmuletItemStats? level2;
  final AmuletItemStats? level3;

  const AmuletItem({
    required this.type,
    required this.subType,
    required this.selectAction,
    required this.level1,
    required this.description,
    required this.levelMin,
    required this.levelMax,
    this.dependency,
    this.level2,
    this.level3,
    this.consumable = false,
  });

  AmuletItemStats? getStatsForLevel(int level) => switch (level) {
        1 => level1,
        2 => level2,
        3 => level3,
        _ => null
      };

  int get totalLevels =>
          level3 != null
              ? 3
              : level2 != null
                  ? 2
                  : 1;

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
    for (final value in values) {
      if (value.name == name) {
        return value;
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

  void validate() {

    if (isWeapon) {
      if (level1.range <= 0) {
        throw Exception('$name: "isWeapon && level1.range <= 0"');
      }
      final lvl2Range = level2?.range;
      if (lvl2Range != null && lvl2Range <= 0) {
        throw Exception('$name: "isWeapon and lvl2Range != null && lvl2Range <= 0"');
      }
      final lvl3Range = level3?.range;
      if (lvl3Range != null && lvl3Range <= 0) {
        throw Exception('$name: "isWeapon and lvl3Range != null && lvl3Range <= 0"');
      }
    }



  }

  static bool statsSupport({
    required AmuletItemStats? stat,
    required int fire,
    required int water,
    required int electricity,
  }) =>
      stat != null &&
      stat.fire <= fire &&
      stat.water <= water &&
      stat.electricity <= electricity;

  int getLevel({
    required int fire,
    required int water,
    required int electricity,
  }) {
     if (statsSupport(
      stat: level3,
      fire: fire,
      water: water,
      electricity: electricity,
    )) {
      return 3;
    }

    if (statsSupport(
      stat: level2,
      fire: fire,
      water: water,
      electricity: electricity,
    )) {
      return 2;
    }

    if (statsSupport(
      stat: level1,
      fire: fire,
      water: water,
      electricity: electricity,
    )) {
      return 1;
    }

    return -1;
  }

}
