
import '../../src.dart';
import '../isometric/treasure_type.dart';



enum AmuletItem {
  Blink_Dagger(
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Sword,
    cooldown: 40,
    range: 180,
    attackType: AmuletAttackType.Blink,
    actionFrame: 15,
    performDuration: 20,
    id: 21,
    level1: ItemStat(information: 'Teleports a short distance'),
  ),
  Lightning_Rod(
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Spell_Thunderbolt,
    cooldown: 40,
    range: 180,
    attackType: AmuletAttackType.Lightning,
    actionFrame: 15,
    performDuration: 20,
    id: 500,
    level1: ItemStat(information: 'Teleports a short distance'),
  ),
  Rusty_Old_Sword(
    quality: AmuletItemQuality.Common,
    type: ItemType.Weapon,
    subType: WeaponType.Sword,
    cooldown: 40,
    damage: 2,
    range: 80,
    attackType: AmuletAttackType.Melee,
    actionFrame: 20,
    performDuration: 25,
    id: 1,
    level1: ItemStat(information: 'An old blunt sword'),
  ),
  Staff_Of_Flames(
    quality: AmuletItemQuality.Unique,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    cooldown: 40,
    damage: 2,
    range: 180,
    attackType: AmuletAttackType.Fire_Ball,
    actionFrame: 20,
    performDuration: 25,
    id: 2,
    level1: ItemStat(information: 'An old blunt sword'),
  ),
  Staff_Of_Frozen_Lake(
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    cooldown: 40,
    damage: 2,
    range: 180,
    attackType: AmuletAttackType.Frost_Ball,
    actionFrame: 15,
    performDuration: 20,
    id: 3,
    level1: ItemStat(information: 'A powerful staff that eliminates cold'),
  ),
  Old_Bow(
    quality: AmuletItemQuality.Common,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    cooldown: 40,
    damage: 1,
    range: 200,
    attackType: AmuletAttackType.Arrow,
    actionFrame: 20,
    performDuration: 30,
    id: 4,
    level1: ItemStat(information: 'A worn out bow'),
  ),
  Holy_Bow(
    quality: AmuletItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    cooldown: 20,
    damage: 100,
    range: 300,
    attackType: AmuletAttackType.Arrow,
    actionFrame: 12,
    performDuration: 25,
    id: 5,
    level1: ItemStat(information: 'A mythical bow which does a lot of damage'),
  ),
  Steel_Helmet(
    quality: AmuletItemQuality.Common,
    type: ItemType.Helm,
    subType: HelmType.Steel,
    health: 10,
    id: 6,
    level1: ItemStat(information: 'A common steel helmet'),
  ),
  Wizards_Hat(
    quality: AmuletItemQuality.Common,
    type: ItemType.Helm,
    subType: HelmType.Wizard_Hat,
    health: 10,
    id: 7,
    level1: ItemStat(information: 'A hat commonly worn by students of magic school'),
  ),
  Travellers_Pants(
    quality: AmuletItemQuality.Common,
    type: ItemType.Legs,
    subType: LegType.Leather,
    health: 2,
    movement: 0.1,
    id: 8,
    level1: ItemStat(information: 'Common pants'),
  ),
  Gauntlet(
    quality: AmuletItemQuality.Common,
    type: ItemType.Hand,
    subType: HandType.Gauntlets,
    health: 2,
    id: 9,
    level1: ItemStat(information: 'Common gauntlets'),
  ),
  Squires_Pants(
    quality: AmuletItemQuality.Common,
    type: ItemType.Legs,
    subType: LegType.Leather,
    health: 3,
    id: 10,
    level1: ItemStat(information: 'Common pants'),
  ),
  Knights_Pants(
    quality: AmuletItemQuality.Unique,
    type: ItemType.Legs,
    subType: LegType.Leather,
    health: 5,
    movement: -0.1,
    id: 11,
    level1: ItemStat(information: 'Pants of higher quality'),
  ),
  Worn_Shirt_Blue (
    quality: AmuletItemQuality.Common,
    type: ItemType.Body,
    subType: BodyType.Shirt_Blue,
    health: 1,
    id: 12,
    level1: ItemStat(information: 'A common blue shirt'),
  ),
  Basic_Leather_Armour (
    quality: AmuletItemQuality.Common,
    type: ItemType.Body,
    subType: BodyType.Leather_Armour,
    health: 5,
    id: 13,
    level1: ItemStat(information: 'Common armour'),
  ),
  Shoe_Leather_Boots (
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    health: 3,
    id: 14,
    level1: ItemStat(information: 'A common leather boots'),
  ),
  Shoe_Iron_Plates (
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    health: 6,
    id: 15,
    level1: ItemStat(information: 'Heavy boots which provide good defense'),
  ),
  Ocean_Boots (
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    health: 6,
    id: 15,
    level1: ItemStat(information: 'Commonly worn by water mages'),
  ),
  Storm_Boots (
    quality: AmuletItemQuality.Common,
    type: ItemType.Shoes,
    subType: ShoeType.Iron_Plates,
    health: 6,
    id: 15,
    level1: ItemStat(information: 'commonly worn by electric mages'),
  ),
  Health_Potion(
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Health_Potion,
    health: 10,
    consumable: true,
    id: 16,
    level1: ItemStat(information: 'Replenishes health'),
  ),
  Treasure_Box(
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Treasure_Box,
    collectable: false,
    experience: 3,
    id: 17,
    level1: ItemStat(information: 'increases experience'),
  ),
  Meat_Drumstick(
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Meat_Drumstick,
    health: 4,
    collectable: false,
    id: 18,
    level1: ItemStat(information: 'replenishes health'),
  ),
  Lost_Pendant_Of_Dreams(
    quality: AmuletItemQuality.Mythical,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    health: 100,
    id: 19,
    level1: ItemStat(information: 'increases stats'),
  ),
  Sapphire_Pendant(
    quality: AmuletItemQuality.Rare,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    health: 5,
    id: 20,
    level1: ItemStat(
      information: 'strikes a random nearby enemy with lightning',
      electricity: 0,
    ),
  ),
  Spell_Thunderbolt(
    quality: AmuletItemQuality.Mythical,
    type: ItemType.Weapon,
    subType: WeaponType.Spell_Thunderbolt,
    id: 19,
    attackType: AmuletAttackType.Lightning,
    cooldown: 10,
    damage: 3,
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
  );

  final int damage;
  final int type;
  final int subType;
  final int cooldown;
  final int health;
  final int experience;
  final bool collectable;
  final bool consumable;
  final double range;
  final double movement;
  final AmuletAttackType? attackType;
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
    required this.level1,
    this.level2,
    this.level3,
    this.level4,
    this.level5,
    this.cooldown = 0,
    this.damage = 0,
    this.range = 0,
    this.health = 0,
    this.collectable = true,
    this.movement = 0,
    this.consumable = false,
    this.experience = 0,
    this.actionFrame = -1,
    this.performDuration = -1,
    this.attackType,
  });

  ItemStat? getItemStatsForLevel(int level) {
    switch (level){
      case 1:
        return level1;
      case 2:
        return level2;
      case 3:
        return level3;
     };
  }

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

  static AmuletItem findByName(String name) =>
      values.firstWhere((element) => element.name == name);

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

    if (attackType != null && performDuration < 0){
      validationError('performDuration cannot be less than 0');
    }

    if (attackType != null && actionFrame < 0){
      validationError('performFrame cannot be less than 0');
    }

    if (attackType != null && actionFrame >= performDuration){
      validationError('performFrame $actionFrame cannot be less than performDuration $performDuration');
    }

    if (attackType != null && range <= 0) {
      validationError('range must be greater than 0');
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
  final String information;

  const ItemStat({
    required this.information,
    this.damage = 0,
    this.cooldown = 0,
    this.fire = 0,
    this.water = 0,
    this.air = 0,
    this.earth = 0,
    this.electricity = 0,
  });
}
