import '../../src.dart';

enum AmuletItem {
  Blink_Dagger(
    selectAction: AmuletItemAction.Positional,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Sword,
    performDuration: 20,
    level1: AmuletItemLevel(
      charges: 1,
      cooldown: 20,
      range: 150,
      air: 0,
      information: 'Teleports a short distance',
      quantity: 2,
      performDuration: 16,
      performActionFrame: 8,
    ),
    level2: AmuletItemLevel(
      charges: 2,
      cooldown: 23,
      range: 160,
      air: 1,
      information: 'teleport slightly further',
      quantity: 3,
      performDuration: 16,
      performActionFrame: 8,
    ),
    level3: AmuletItemLevel(
      charges: 2,
      cooldown: 21,
      range: 170,
      air: 2,
      information: 'teleports a short distance',
      quantity: 4,
      performDuration: 16,
      performActionFrame: 8,
    ),
  ),
  Weapon_Rusty_Old_Sword(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Weapon,
    subType: WeaponType.Sword,
    performDuration: 25,
    level1: AmuletItemLevel(
      damage: 1,
      range: 60,
      cooldown: 5,
      charges: 5,
      information: 'An old blunt sword',
      performDuration: 30,
      performActionFrame: 20,
    ),
    level2: AmuletItemLevel(
      damage: 2,
      range: 60,
      cooldown: 5,
      charges: 7,
      information: 'An old blunt sword',
      earth: 1,
      performDuration: 30,
      performActionFrame: 20,
    ),
    level3: AmuletItemLevel(
      damage: 4,
      range: 60,
      cooldown: 5,
      charges: 7,
      information: 'An old blunt sword',
      earth: 5,
      performDuration: 25,
      performActionFrame: 18,
    ),
  ),
  Weapon_Staff_Of_Flames(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Unique,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    performDuration: 25,
    level1: AmuletItemLevel(
        range: 100,
        damage: 1,
        information: 'An old blunt sword',
    ),
  ),
  Weapon_Staff_Of_Frozen_Lake(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    performDuration: 20,
    level1: AmuletItemLevel(
        range: 100,
        damage: 1,
        information: 'A powerful staff that eliminates cold',
    ),
  ),
  Weapon_Old_Bow(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    performDuration: 30,
    level1: AmuletItemLevel(
      information: 'A worn out bow',
      damage: 1,
      charges: 5,
      cooldown: 4,
      range: 150,
    ),
    level2: AmuletItemLevel(
      information: 'A worn out bow',
      damage: 2,
      charges: 6,
      cooldown: 4,
      range: 160,
      air: 2,
    ),
    level3: AmuletItemLevel(
      information: 'A worn out bow',
      damage: 3,
      charges: 6,
      cooldown: 3,
      range: 170,
      air: 5,
    ),
  ),
  Weapon_Holy_Bow(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    performDuration: 25,
    level1: AmuletItemLevel(
        range: 150,
        damage: 5,
        cooldown: 15,
        charges: 3,
        information: 'A mythical bow which does a lot of damage',
    ),
    level2: AmuletItemLevel(
      air: 1,
      range: 160,
      damage: 8,
      cooldown: 38,
      charges: 3,
      information: 'A mythical bow which does a lot of damage',
    ),
    level3: AmuletItemLevel(
      air: 2,
      range: 170,
      damage: 12,
      cooldown: 36,
      charges: 3,
      information: 'A mythical bow which does a lot of damage',
    ),
  ),
  Helm_Steel(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Helm,
    subType: HelmType.Steel,
    level1: AmuletItemLevel(information: 'A common steel helmet'),
  ),
  Helm_Wizards_Hat(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Helm,
    subType: HelmType.Wizard_Hat,
    level1: AmuletItemLevel(
        information: 'A hat commonly worn by students of magic school'),
  ),
  Pants_Travellers(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Legs,
    subType: LegType.Leather,
    level1: AmuletItemLevel(information: 'Common pants'),
  ),
  Pants_Squires(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Legs,
    subType: LegType.Leather,
    level1: AmuletItemLevel(information: 'Common pants'),
  ),
  Pants_Plated(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Unique,
    type: ItemType.Legs,
    subType: LegType.Leather,
    level1: AmuletItemLevel(information: 'Pants of higher quality'),
  ),
  Gauntlet(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Hand,
    subType: HandType.Gauntlets,
    level1: AmuletItemLevel(information: 'Common gauntlets'),
  ),
  Armor_Shirt_Blue_Worn(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Body,
    subType: BodyType.Shirt_Blue,
    level1: AmuletItemLevel(information: 'A common blue shirt'),
  ),
  Armor_Leather_Basic(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Body,
    subType: BodyType.Leather_Armour,
    level1: AmuletItemLevel(information: 'Common armour'),
  ),
  Shoe_Leather_Boots(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    level1: AmuletItemLevel(information: 'A common leather boots'),
  ),
  Shoe_Iron_Plates(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    level1: AmuletItemLevel(information: 'Heavy boots which provide good defense'),
  ),
  Shoe_Ocean_Boots(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    level1: AmuletItemLevel(information: 'Commonly worn by water mages'),
  ),
  Shoe_Storm_Boots(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    level1: AmuletItemLevel(information: 'commonly worn by electric mages'),
  ),
  Health_Potion(
    selectAction: AmuletItemAction.Consume,
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Health_Potion,
    consumable: true,
    level1: AmuletItemLevel(information: 'Replenishes health'),
  ),
  Treasure_Box(
    selectAction: AmuletItemAction.Consume,
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Treasure_Box,
    collectable: false,
    level1: AmuletItemLevel(information: 'increases experience'),
  ),
  Meat_Drumstick(
    selectAction: AmuletItemAction.Consume,
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Meat_Drumstick,
    collectable: false,
    level1: AmuletItemLevel(information: 'replenishes health'),
  ),
  Lost_Pendant_Of_Dreams(
    selectAction: AmuletItemAction.None,
    quality: AmuletItemQuality.Mythical,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    level1: AmuletItemLevel(information: 'increases stats'),
  ),
  Sapphire_Pendant(
    selectAction: AmuletItemAction.None,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    level1: AmuletItemLevel(
      information: 'strikes a random nearby enemy with lightning',
      electricity: 0,
    ),
  ),
  Spell_Thunderbolt(
    selectAction: AmuletItemAction.Caste,
    quality: AmuletItemQuality.Mythical,
    type: ItemType.Spell,
    subType: SpellType.Thunderbolt,
    level1: AmuletItemLevel(
      damage: 3,
      cooldown: 30,
      charges: 2,
      information: 'strikes one random nearby enemy with lightning',
      electricity: 0,
      range: 100,
    ),
    level2: AmuletItemLevel(
      damage: 4,
      cooldown: 28,
      charges: 2,
      information: 'strikes two random nearby enemies with lightning',
      electricity: 3,
      fire: 1,
      range: 150,
    ),
    level3: AmuletItemLevel(
      damage: 5,
      cooldown: 26,
      charges: 2,
      information: 'strikes three random nearby enemies with lightning',
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
      level1: AmuletItemLevel(
        cooldown: 30,
        information: 'teleports a short distance',
        air: 2,
        range: 50,
      ),
      level2: AmuletItemLevel(
        cooldown: 28,
        information: 'teleports a short distance',
        air: 4,
        range: 60,
      ),
      level3: AmuletItemLevel(
        cooldown: 26,
        information: 'teleports a short distance',
        air: 7,
        range: 70,
      ),
      level4: AmuletItemLevel(
        cooldown: 26,
        information: 'teleports a short distance',
        air: 8,
        range: 70,
      ),
      level5: AmuletItemLevel(
        cooldown: 24,
        information: 'teleports a short distance',
        air: 16,
        range: 80,
      )),
  Spell_Heal(
      selectAction: AmuletItemAction.Caste,
      quality: AmuletItemQuality.Mythical,
      type: ItemType.Spell,
      subType: SpellType.Heal,
      level1: AmuletItemLevel(
        information: 'heals a small amount of health',
        charges: 1,
        cooldown: 30,
        health: 3,
        performDuration: 25,
        performActionFrame: 20,
      ),
      level2: AmuletItemLevel(
        cooldown: 28,
        information: 'heals a small amount of health',
        health: 5,
        water: 1,
        performDuration: 25,
        performActionFrame: 20,
      ),
      level3: AmuletItemLevel(
        cooldown: 26,
        information: 'heals a small amount of health',
        health: 7,
        water: 5,
        performDuration: 25,
        performActionFrame: 20,
      ),
      level4: AmuletItemLevel(
        cooldown: 25,
        information: 'heals a small amount of health',
        health: 12,
        water: 8,
        performDuration: 25,
        performActionFrame: 20,
      ),
      level5: AmuletItemLevel(
        cooldown: 24,
        information: 'heals a small amount of health',
        health: 7,
        water: 16,
        performDuration: 25,
        performActionFrame: 20,
      ));

  final AmuletItemAction selectAction;
  final int type;
  final int subType;
  final bool collectable;
  final bool consumable;
  final AmuletItemQuality quality;
  final int performDuration;
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
    this.level2,
    this.level3,
    this.level4,
    this.level5,
    this.collectable = true,
    this.consumable = false,
    this.performDuration = -1,
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
    required int air,
    required int earth,
    required int electricity,
  }) =>
      stat != null &&
      stat.fire <= fire &&
      stat.water <= water &&
      stat.air <= air &&
      stat.earth <= earth &&
      stat.electricity <= electricity;

  int getLevel({
    required int fire,
    required int water,
    required int wind,
    required int earth,
    required int electricity,
  }) {
    if (statsSupport(
      stat: this.level5,
      fire: fire,
      water: water,
      air: wind,
      earth: earth,
      electricity: electricity,
    )) {
      return 5;
    }

    if (statsSupport(
      stat: this.level4,
      fire: fire,
      water: water,
      air: wind,
      earth: earth,
      electricity: electricity,
    )) {
      return 4;
    }

    if (statsSupport(
      stat: this.level3,
      fire: fire,
      water: water,
      air: wind,
      earth: earth,
      electricity: electricity,
    )) {
      return 3;
    }

    if (statsSupport(
      stat: this.level2,
      fire: fire,
      water: water,
      air: wind,
      earth: earth,
      electricity: electricity,
    )) {
      return 2;
    }

    if (statsSupport(
      stat: this.level1,
      fire: fire,
      water: water,
      air: wind,
      earth: earth,
      electricity: electricity,
    )) {
      return 1;
    }

    return -1;
  }

}
