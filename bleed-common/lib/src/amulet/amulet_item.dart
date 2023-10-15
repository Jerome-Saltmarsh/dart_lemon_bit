import '../../src.dart';

enum AmuletItem {
  Blink_Dagger(
    selectAction: AmuletItemAction.Positional,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Sword,
    actionFrame: 15,
    performDuration: 20,
    level1: ItemStat(
      charges: 1,
      cooldown: 20,
      range: 150,
      air: 0,
      information: 'Teleports a short distance',
      quantity: 2,
    ),
    level2: ItemStat(
      charges: 2,
      cooldown: 23,
      range: 160,
      air: 1,
      information: 'teleport slightly further',
      quantity: 3,
    ),
    level3: ItemStat(
      charges: 2,
      cooldown: 21,
      range: 170,
      air: 2,
      information: 'teleports a short distance',
      quantity: 4,
    ),
  ),
  Rusty_Old_Sword(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Weapon,
    subType: WeaponType.Sword,
    actionFrame: 20,
    performDuration: 25,
    level1: ItemStat(
      damage: 1,
      range: 60,
      cooldown: 20,
      charges: 5,
      information: 'An old blunt sword',
    ),
  ),
  Staff_Of_Flames(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Unique,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    actionFrame: 20,
    performDuration: 25,
    level1: ItemStat(information: 'An old blunt sword'),
  ),
  Staff_Of_Frozen_Lake(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    actionFrame: 15,
    performDuration: 20,
    level1: ItemStat(information: 'A powerful staff that eliminates cold'),
  ),
  Old_Bow(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    actionFrame: 20,
    performDuration: 30,
    level1: ItemStat(
      information: 'A worn out bow',
      damage: 1,
      charges: 5,
      cooldown: 4,
    ),
    level2: ItemStat(
      information: 'A worn out bow',
      damage: 2,
      charges: 6,
      cooldown: 4,
    ),
    level3: ItemStat(
      information: 'A worn out bow',
      damage: 3,
      charges: 6,
      cooldown: 3,
    ),
  ),
  Holy_Bow(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    actionFrame: 12,
    performDuration: 25,
    level1: ItemStat(
        range: 150,
        damage: 5,
        cooldown: 40,
        information: 'A mythical bow which does a lot of damage'),
    level2: ItemStat(
      air: 1,
      range: 160,
      damage: 8,
      cooldown: 38,
      information: 'A mythical bow which does a lot of damage',
    ),
    level3: ItemStat(
      air: 2,
      range: 170,
      damage: 12,
      cooldown: 36,
      information: 'A mythical bow which does a lot of damage',
    ),
  ),
  Steel_Helmet(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Helm,
    subType: HelmType.Steel,
    level1: ItemStat(information: 'A common steel helmet'),
  ),
  Wizards_Hat(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Helm,
    subType: HelmType.Wizard_Hat,
    level1: ItemStat(
        information: 'A hat commonly worn by students of magic school'),
  ),
  Travellers_Pants(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Legs,
    subType: LegType.Leather,
    level1: ItemStat(information: 'Common pants'),
  ),
  Gauntlet(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Hand,
    subType: HandType.Gauntlets,
    level1: ItemStat(information: 'Common gauntlets'),
  ),
  Squires_Pants(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Legs,
    subType: LegType.Leather,
    level1: ItemStat(information: 'Common pants'),
  ),
  Knights_Pants(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Unique,
    type: ItemType.Legs,
    subType: LegType.Leather,
    level1: ItemStat(information: 'Pants of higher quality'),
  ),
  Worn_Shirt_Blue(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Body,
    subType: BodyType.Shirt_Blue,
    level1: ItemStat(information: 'A common blue shirt'),
  ),
  Basic_Leather_Armour(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Body,
    subType: BodyType.Leather_Armour,
    level1: ItemStat(information: 'Common armour'),
  ),
  Shoe_Leather_Boots(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    level1: ItemStat(information: 'A common leather boots'),
  ),
  Shoe_Iron_Plates(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    level1: ItemStat(information: 'Heavy boots which provide good defense'),
  ),
  Ocean_Boots(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    level1: ItemStat(information: 'Commonly worn by water mages'),
  ),
  Storm_Boots(
    selectAction: AmuletItemAction.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    level1: ItemStat(information: 'commonly worn by electric mages'),
  ),
  Health_Potion(
    selectAction: AmuletItemAction.Consume,
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Health_Potion,
    consumable: true,
    level1: ItemStat(information: 'Replenishes health'),
  ),
  Treasure_Box(
    selectAction: AmuletItemAction.Consume,
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Treasure_Box,
    collectable: false,
    level1: ItemStat(information: 'increases experience'),
  ),
  Meat_Drumstick(
    selectAction: AmuletItemAction.Consume,
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Meat_Drumstick,
    collectable: false,
    level1: ItemStat(information: 'replenishes health'),
  ),
  Lost_Pendant_Of_Dreams(
    selectAction: AmuletItemAction.None,
    quality: AmuletItemQuality.Mythical,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    level1: ItemStat(information: 'increases stats'),
  ),
  Sapphire_Pendant(
    selectAction: AmuletItemAction.None,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    level1: ItemStat(
      information: 'strikes a random nearby enemy with lightning',
      electricity: 0,
    ),
  ),
  Spell_Thunderbolt(
    selectAction: AmuletItemAction.Caste,
    quality: AmuletItemQuality.Mythical,
    type: ItemType.Weapon,
    subType: WeaponType.Spell_Thunderbolt,
    level1: ItemStat(
      damage: 3,
      cooldown: 30,
      information: 'strikes one random nearby enemy with lightning',
      electricity: 0,
    ),
    level2: ItemStat(
      damage: 4,
      cooldown: 28,
      information: 'strikes two random nearby enemies with lightning',
      electricity: 3,
      fire: 1,
    ),
    level3: ItemStat(
      damage: 5,
      cooldown: 26,
      information: 'strikes three random nearby enemies with lightning',
      electricity: 6,
      fire: 2,
    ),
  ),
  Spell_Blink(
      selectAction: AmuletItemAction.Positional,
      quality: AmuletItemQuality.Mythical,
      type: ItemType.Spell,
      subType: SpellType.Blink,
      level1: ItemStat(
        cooldown: 30,
        information: 'teleports a short distance',
        air: 2,
        range: 50,
      ),
      level2: ItemStat(
        cooldown: 28,
        information: 'teleports a short distance',
        air: 4,
        range: 60,
      ),
      level3: ItemStat(
        cooldown: 26,
        information: 'teleports a short distance',
        air: 7,
        range: 70,
      ),
      level4: ItemStat(
        cooldown: 26,
        information: 'teleports a short distance',
        air: 8,
        range: 70,
      ),
      level5: ItemStat(
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
      level1: ItemStat(
        cooldown: 30,
        information: 'heals a small amount of health',
        health: 5,
        water: 2,
      ),
      level2: ItemStat(
        cooldown: 28,
        information: 'teleports a short distance',
        health: 7,
        water: 4,
      ),
      level3: ItemStat(
        cooldown: 26,
        information: 'teleports a short distance',
        health: 7,
        water: 7,
      ),
      level4: ItemStat(
        cooldown: 26,
        information: 'teleports a short distance',
        health: 7,
        water: 8,
      ),
      level5: ItemStat(
        cooldown: 24,
        information: 'teleports a short distance',
        health: 7,
        water: 16,
      ));

  final AmuletItemAction selectAction;
  final int type;
  final int subType;
  final bool collectable;
  final bool consumable;
  final AmuletItemQuality quality;
  final int actionFrame;
  final int performDuration;
  final ItemStat level1;
  final ItemStat? level2;
  final ItemStat? level3;
  final ItemStat? level4;
  final ItemStat? level5;

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
    this.actionFrame = -1,
    this.performDuration = -1,
  });

  ItemStat? getStatsForLevel(int level) => switch (level) {
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
    if (actionFrame > performDuration) {
      validationError('performFrame cannot be greater than performDuration');
    }
  }

  void validationError(String reason) =>
      print('validation_error: {name: $this, reason: $reason}');

  static bool statsSupport({
    required ItemStat? stat,
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
