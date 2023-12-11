import '../../src.dart';

enum AmuletItem {
  Blink_Dagger(
    selectAction: AmuletItemAction.Positional,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Sword,
    description: 'Teleports a short distance',
    level1: AmuletItemLevel(
      charges: 1,
      cooldown: 20,
      range: 150,
      performDuration: 16,
    ),
    level2: AmuletItemLevel(
      charges: 2,
      cooldown: 23,
      range: 160,
      performDuration: 16,
    ),
    level3: AmuletItemLevel(
      charges: 2,
      cooldown: 21,
      range: 170,
      performDuration: 16,
    ),
  ),
  Weapon_Rusty_Old_Sword(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Weapon,
    subType: WeaponType.Sword,
    description: 'An old blunt sword',
    level1: AmuletItemLevel(
      damage: 1,
      range: 60,
      cooldown: 1,
      charges: 1,
      performDuration: 32,
    ),
    level2: AmuletItemLevel(
      damage: 2,
      range: 60,
      cooldown: 4,
      charges: 7,
      performDuration: 28,
      fire: 1,
    ),
    level3: AmuletItemLevel(
      damage: 4,
      range: 60,
      cooldown: 4,
      charges: 7,
      performDuration: 26,
      fire: 3,
    ),
  ),
  Weapon_Staff_Of_Flames(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Unique,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    description: 'An ancient staff of that emits a red glowing amber',
    level1: AmuletItemLevel(
        range: 100,
        damage: 1,
        fire: 10,
    ),
  ),
  Weapon_Staff_Of_Frozen_Lake(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    description: 'A powerful staff that eliminates cold',
    level1: AmuletItemLevel(
        range: 100,
        damage: 1,
    ),
  ),
  Spell_Split_Arrow(
    dependency: WeaponType.Bow,
    type: ItemType.Spell,
    subType: SpellType.Split_Arrow,
    quality: AmuletItemQuality.Common,
    description: 'fires multiple arrows',
    level1: AmuletItemLevel(
      damage: 1,
      fire: 0,
      charges: 3,
      cooldown: 30,
      performDuration: 25,
      quantity: 3,
    ),
    level2: AmuletItemLevel(
      damage: 2,
      fire: 3,
      water: 2,
      electricity: 1,
      charges: 3,
      cooldown: 30,
      performDuration: 25,
      quantity: 4,
    ),
    selectAction: AmuletItemAction.Directional,
  ),
  Weapon_Old_Bow(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    description: 'A worn out bow',
    level1: AmuletItemLevel(
      damage: 1,
      charges: 3,
      cooldown: 8,
      range: 150,
      performDuration: 20,
      electricity: 0,
    ),
    level2: AmuletItemLevel(
      damage: 2,
      charges: 3,
      cooldown: 9,
      range: 160,
      performDuration: 18,
      electricity: 2,
    ),
    level3: AmuletItemLevel(
      damage: 5,
      charges: 4,
      cooldown: 9,
      range: 160,
      performDuration: 18,
      electricity: 6,
    ),
    level4: AmuletItemLevel(
      damage: 3,
      charges: 4,
      cooldown: 8,
      range: 165,
      performDuration: 17,
      electricity: 10,
    ),
  ),
  Weapon_Holy_Bow(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    description: 'A mythical bow which does a lot of damage',
    level1: AmuletItemLevel(
        range: 150,
        damage: 5,
        cooldown: 15,
        charges: 3,
    ),
    level2: AmuletItemLevel(
      range: 160,
      damage: 8,
      cooldown: 38,
      charges: 3,
    ),
    level3: AmuletItemLevel(
      range: 170,
      damage: 12,
      cooldown: 36,
      charges: 3,
    ),
  ),
  Helm_Steel(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    description: 'An ordinary helmet made of steel',
    type: ItemType.Helm,
    subType: HelmType.Steel,
    level1: AmuletItemLevel(),
  ),
  Helm_Wizards_Hat(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Helm,
    subType: HelmType.Wizard_Hat,
    description: 'A hat commonly worn by students of magic school',
    level1: AmuletItemLevel(),
  ),
  Pants_Travellers(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Legs,
    subType: LegType.Leather,
    description: 'Common pants made for more for comfort than combat',
    level1: AmuletItemLevel(),
  ),
  Pants_Squires(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Legs,
    subType: LegType.Leather,
    description: 'light pants which provide easy movement with some protection',
    level1: AmuletItemLevel(),
  ),
  Pants_Plated(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Unique,
    type: ItemType.Legs,
    subType: LegType.Leather,
    description: 'Quite heavy but they offer a lot of protection',
    level1: AmuletItemLevel(),
  ),
  Gauntlet(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Hand,
    subType: HandType.Gauntlets,
    description: 'Common gauntlets',
    level1: AmuletItemLevel(),
  ),
  Leather_Gloves(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Hand,
    subType: HandType.Leather_Gloves,
    description: 'Common leather gloves',
    level1: AmuletItemLevel(
      health: 5,
    ),
  ),
  Armor_Shirt_Blue_Worn(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Body,
    subType: BodyType.Shirt_Blue,
    description: 'An ordinary shirt',
    level1: AmuletItemLevel(
      health: 10,
    ),
  ),
  Armor_Leather_Basic(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Body,
    subType: BodyType.Leather_Armour,
    description: 'Common armour',
    level1: AmuletItemLevel(
      health: 15
    ),
  ),
  Shoe_Leather_Boots(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    description: 'A common leather boots',
    level1: AmuletItemLevel(),
  ),
  Shoe_Iron_Plates(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    description: 'Heavy boots which provide good defense',
    level1: AmuletItemLevel(),
  ),
  Shoe_Ocean_Boots(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    description: 'Commonly worn by water mages',
    level1: AmuletItemLevel(),
  ),
  Shoe_Storm_Boots(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    description: 'commonly worn by electric mages',
    level1: AmuletItemLevel(),
  ),
  Potion_Health(
    selectAction: AmuletItemAction.Consume,
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Red,
    consumable: true,
    description: 'Replenishes health',
    level1: AmuletItemLevel(
      health: 5,
    ),
  ),
  Potion_Magic(
    selectAction: AmuletItemAction.Consume,
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Blue,
    consumable: true,
    description: 'reduces cooldowns',
    level1: AmuletItemLevel(),
  ),
  Potion_Experience(
    selectAction: AmuletItemAction.Consume,
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Yellow,
    description: 'increases experience',
    consumable: true,
    level1: AmuletItemLevel(),
  ),
  Lost_Pendant_Of_Dreams(
    selectAction: AmuletItemAction.None,
    quality: AmuletItemQuality.Mythical,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    description: 'increases stats',
    level1: AmuletItemLevel(),
  ),
  Sapphire_Pendant(
    selectAction: AmuletItemAction.None,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    description: 'a radian blue pendant',
    level1: AmuletItemLevel(),
  ),
  Spell_Thunderbolt(
    selectAction: AmuletItemAction.Caste,
    quality: AmuletItemQuality.Mythical,
    type: ItemType.Spell,
    subType: SpellType.Thunderbolt,
    description: 'strikes random nearby enemies with lightning',
    level1: AmuletItemLevel(
      damage: 3,
      cooldown: 30,
      charges: 2,
      electricity: 0,
      range: 100,
      quantity: 1,
    ),
    level2: AmuletItemLevel(
      damage: 4,
      cooldown: 28,
      charges: 2,
      electricity: 3,
      fire: 1,
      range: 150,
    ),
    level3: AmuletItemLevel(
      damage: 5,
      cooldown: 26,
      charges: 2,
      electricity: 6,
      fire: 2,
      range: 200,
    ),
  ),
  Spell_Blink(
      selectAction: AmuletItemAction.Positional,
      quality: AmuletItemQuality.Mythical,
      type: ItemType.Spell,
      subType: SpellType.Blink,
      description: 'strikes one random nearby enemy with lightning',
      level1: AmuletItemLevel(
        cooldown: 30,
        range: 50,
      ),
      level2: AmuletItemLevel(
        cooldown: 28,
        range: 60,
      ),
      level3: AmuletItemLevel(
        cooldown: 26,
        range: 70,
      ),
      level4: AmuletItemLevel(
        cooldown: 26,
        range: 70,
      ),
      level5: AmuletItemLevel(
        cooldown: 24,
        range: 80,
      )),
  Spell_Heal(
      selectAction: AmuletItemAction.Caste,
      quality: AmuletItemQuality.Common,
      type: ItemType.Spell,
      subType: SpellType.Heal,
      description: 'heals a small amount of health',
      level1: AmuletItemLevel(
        charges: 1,
        cooldown: 30,
        health: 3,
        performDuration: 25,
        water: 0,
      ),
      level2: AmuletItemLevel(
        charges: 1,
        cooldown: 30,
        health: 6,
        performDuration: 23,
        water: 3,
      ),
      level3: AmuletItemLevel(
        charges: 1,
        cooldown: 30,
        health: 10,
        performDuration: 21,
        water: 6,
      ),
      level4: AmuletItemLevel(
        charges: 1,
        cooldown: 30,
        health: 16,
        performDuration: 18,
        water: 12,
      ),
      level5: AmuletItemLevel(
        charges: 1,
        cooldown: 30,
        health: 30,
        performDuration: 16,
        water: 20,
      ));

  final String description;
  /// this is used by spells which required certain weapons to be equipped
  /// for example split arrow depends on a bow
  final int? dependency;
  final AmuletItemAction selectAction;
  final int type;
  final int subType;
  final bool consumable;
  final AmuletItemQuality quality;
  final AmuletItemLevel level1;
  final AmuletItemLevel? level2;
  final AmuletItemLevel? level3;
  final AmuletItemLevel? level4;
  final AmuletItemLevel? level5;

  const AmuletItem({
    required this.type,
    required this.subType,
    required this.quality,
    required this.selectAction,
    required this.level1,
    required this.description,
    this.dependency,
    this.level2,
    this.level3,
    this.level4,
    this.level5,
    this.consumable = false,
  });

  AmuletItemLevel? getStatsForLevel(int level) => switch (level) {
        1 => level1,
        2 => level2,
        3 => level3,
        4 => level4,
        5 => level5,
        _ => null
      };

  int get totalLevels => level5 != null
      ? 5
      : level4 != null
          ? 4
          : level3 != null
              ? 3
              : level2 != null
                  ? 2
                  : 1;

  bool get isWeaponStaff => isWeapon && subType == WeaponType.Staff;

  bool get isWeaponSword => isWeapon && subType == WeaponType.Sword;

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

  static final valuesCommon = _findByQuality(AmuletItemQuality.Common);

  static final valuesUnique = _findByQuality(AmuletItemQuality.Unique);

  static final valuesRare = _findByQuality(AmuletItemQuality.Rare);

  static final valuesMythical = _findByQuality(AmuletItemQuality.Mythical);

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

  static List<AmuletItem> _findByQuality(AmuletItemQuality quality) =>
      values.where((item) => item.quality == quality).toList(growable: false);

  static List<AmuletItem> findByQuality(AmuletItemQuality quality) =>
      switch (quality) {
        AmuletItemQuality.Common => valuesCommon,
        AmuletItemQuality.Unique => valuesUnique,
        AmuletItemQuality.Rare => valuesRare,
        AmuletItemQuality.Mythical => valuesMythical,
      };

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
      final lvl4Range = level4?.range;
      if (lvl4Range != null && lvl4Range <= 0) {
        throw Exception('$name: "isWeapon and lvl4Range != null && lvl4Range <= 0"');
      }
      final lvl5ange = level5?.range;
      if (lvl5ange != null && lvl5ange <= 0) {
        throw Exception('$name: "isWeapon and lvl5ange != null && lvl5ange <= 0"');
      }
    }



  }

  static bool statsSupport({
    required AmuletItemLevel? stat,
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
      stat: level5,
      fire: fire,
      water: water,
      electricity: electricity,
    )) {
      return 5;
    }

    if (statsSupport(
      stat: level4,
      fire: fire,
      water: water,
      electricity: electricity,
    )) {
      return 4;
    }

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
