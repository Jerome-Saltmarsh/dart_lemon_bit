
import '../../src.dart';

enum AmuletItem {
  Blink_Dagger(
    powerMode: AmuletPowerMode.Positional,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Sword,
    actionFrame: 15,
    performDuration: 20,
    id: 21,
    level1: ItemStat(
        air: 5,
        information: 'Teleports a short distance',
    ),
    level2: ItemStat(
        air: 10,
        information: 'teleport slightly further',
    )
  ),
  Rusty_Old_Sword(
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Weapon,
    subType: WeaponType.Sword,
    actionFrame: 20,
    performDuration: 25,
    id: 1,
    level1: ItemStat(information: 'An old blunt sword'),
  ),
  Staff_Of_Flames(
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Unique,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    actionFrame: 20,
    performDuration: 25,
    id: 2,
    level1: ItemStat(information: 'An old blunt sword'),
  ),
  Staff_Of_Frozen_Lake(
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    actionFrame: 15,
    performDuration: 20,
    id: 3,
    level1: ItemStat(information: 'A powerful staff that eliminates cold'),
  ),
  Old_Bow(
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    actionFrame: 20,
    performDuration: 30,
    id: 4,
    level1: ItemStat(information: 'A worn out bow'),
  ),
  Holy_Bow(
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    actionFrame: 12,
    performDuration: 25,
    id: 5,
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
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Helm,
    subType: HelmType.Steel,
    id: 6,
    level1: ItemStat(information: 'A common steel helmet'),
  ),
  Wizards_Hat(
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Helm,
    subType: HelmType.Wizard_Hat,
    id: 7,
    level1: ItemStat(information: 'A hat commonly worn by students of magic school'),
  ),
  Travellers_Pants(
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Legs,
    subType: LegType.Leather,
    id: 8,
    level1: ItemStat(information: 'Common pants'),
  ),
  Gauntlet(
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Hand,
    subType: HandType.Gauntlets,
    id: 9,
    level1: ItemStat(information: 'Common gauntlets'),
  ),
  Squires_Pants(
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Legs,
    subType: LegType.Leather,
    id: 10,
    level1: ItemStat(information: 'Common pants'),
  ),
  Knights_Pants(
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Unique,
    type: ItemType.Legs,
    subType: LegType.Leather,
    id: 11,
    level1: ItemStat(information: 'Pants of higher quality'),
  ),
  Worn_Shirt_Blue (
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Body,
    subType: BodyType.Shirt_Blue,
    id: 12,
    level1: ItemStat(information: 'A common blue shirt'),
  ),
  Basic_Leather_Armour (
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Body,
    subType: BodyType.Leather_Armour,
    id: 13,
    level1: ItemStat(information: 'Common armour'),
  ),
  Shoe_Leather_Boots (
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    id: 14,
    level1: ItemStat(information: 'A common leather boots'),
  ),
  Shoe_Iron_Plates (
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    id: 15,
    level1: ItemStat(information: 'Heavy boots which provide good defense'),
  ),
  Ocean_Boots (
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    id: 15,
    level1: ItemStat(information: 'Commonly worn by water mages'),
  ),
  Storm_Boots (
    powerMode: AmuletPowerMode.Equip,
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    id: 15,
    level1: ItemStat(information: 'commonly worn by electric mages'),
  ),
  Health_Potion(
    powerMode: AmuletPowerMode.Self,
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Health_Potion,
    consumable: true,
    id: 16,
    level1: ItemStat(information: 'Replenishes health'),
  ),
  Treasure_Box(
    powerMode: AmuletPowerMode.Self,
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Treasure_Box,
    collectable: false,
    id: 17,
    level1: ItemStat(information: 'increases experience'),
  ),
  Meat_Drumstick(
    powerMode: AmuletPowerMode.Self,
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Meat_Drumstick,
    collectable: false,
    id: 18,
    level1: ItemStat(information: 'replenishes health'),
  ),
  Lost_Pendant_Of_Dreams(
    powerMode: AmuletPowerMode.None,
    quality: AmuletItemQuality.Mythical,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    id: 19,
    level1: ItemStat(information: 'increases stats'),
  ),
  Sapphire_Pendant(
    powerMode: AmuletPowerMode.None,
    quality: AmuletItemQuality.Rare,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    id: 20,
    level1: ItemStat(
      information: 'strikes a random nearby enemy with lightning',
      electricity: 0,
    ),
  ),
  Spell_Thunderbolt(
    powerMode: AmuletPowerMode.Self,
    quality: AmuletItemQuality.Mythical,
    type: ItemType.Weapon,
    subType: WeaponType.Spell_Thunderbolt,
    id: 19,
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
    powerMode: AmuletPowerMode.Positional,
    quality: AmuletItemQuality.Mythical,
    type: ItemType.Spell,
    subType: SpellType.Blink,
    id: 100,
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
  );

  final AmuletPowerMode powerMode;
  final int type;
  final int subType;
  final bool collectable;
  final bool consumable;
  final AmuletItemQuality quality;
  final int actionFrame;
  final int performDuration;
  final int id;
  final ItemStat level1;
  final ItemStat? level2;
  final ItemStat? level3;
  final ItemStat? level4;
  final ItemStat? level5;

  const AmuletItem({
    required this.type,
    required this.subType,
    required this.quality,
    required this.id,
    required this.powerMode,
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

  ItemStat? getStatsForLevel(int level) =>
      switch (level){
        1 => level1,
        2 => level2,
        3 => level3,
        _ => null
     };

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

  static final typeBodies = values.where((element) => element.isBody).toList(growable: false);
  static final typeHelms = values.where((element) => element.isHelm).toList(growable: false);
  static final typeShoes = values.where((element) => element.isShoes).toList(growable: false);
  static final typeWeapons = values.where((element) => element.isWeapon).toList(growable: false);
  static final typeHands = values.where((element) => element.isHand).toList(growable: false);
  static final typeLegs = values.where((element) => element.isLegs).toList(growable: false);

  static AmuletItem getBody(int type) =>
      typeBodies.firstWhere((element) => element.subType == type);

  static AmuletItem getShoe(int type) =>
      typeShoes.firstWhere((element) => element.subType == type);

  static AmuletItem getWeapon(int type) =>
      typeWeapons.firstWhere((element) => element.subType == type);

  static AmuletItem? findByName(String name) {
     for (final value in values){
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
  }) => values.firstWhere((element) =>
    element.type == type &&
    element.subType == subType
  );

  void validate(){
    if (actionFrame > performDuration){
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


class ItemStat {
  final int damage;
  final int cooldown;
  final int fire;
  final int water;
  final int air;
  final int earth;
  final int electricity;
  final int health;
  final double range;
  final double movement;
  final String information;

  const ItemStat({
    required this.information,
    this.damage = 0,
    this.health = 0,
    this.range = 0,
    this.cooldown = 0,
    this.fire = 0,
    this.water = 0,
    this.air = 0,
    this.earth = 0,
    this.electricity = 0,
    this.movement = 0,
  });
}
