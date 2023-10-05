
import '../../src.dart';
import '../isometric/treasure_type.dart';

// fire: 5


const Levels_Blink_Dagger = [
  {
    AmuletElement.electricity: 2,
    AmuletElement.earth: 1,
  },
  {
    AmuletElement.electricity: 4,
    AmuletElement.earth: 2,
  },
  {
    AmuletElement.electricity: 8,
    AmuletElement.earth: 4,
  },
  {
    AmuletElement.electricity: 15,
    AmuletElement.earth: 6,
  },
];

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
    id: 21,
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
  ),
  Steel_Helmet(
      quality: AmuletItemQuality.Common,
      type: ItemType.Helm,
      subType: HelmType.Steel,
      health: 10,
      id: 6,
  ),
  Wizards_Hat(
      quality: AmuletItemQuality.Common,
      type: ItemType.Helm,
      subType: HelmType.Wizard_Hat,
      health: 10,
      id: 7,
  ),
  Travellers_Pants(
      quality: AmuletItemQuality.Common,
      type: ItemType.Legs,
      subType: LegType.Leather,
      health: 2,
      movement: 0.1,
      id: 8,
  ),
  Gauntlet(
      quality: AmuletItemQuality.Common,
      type: ItemType.Hand,
      subType: HandType.Gauntlets,
      health: 2,
      id: 9,
  ),
  Squires_Pants(
      quality: AmuletItemQuality.Common,
      type: ItemType.Legs,
      subType: LegType.Leather,
      health: 3,
      id: 10,
  ),
  Knights_Pants(
      quality: AmuletItemQuality.Unique,
      type: ItemType.Legs,
      subType: LegType.Leather,
      health: 5,
      movement: -0.1,
    id: 11,
  ),
  Worn_Shirt_Blue (
      quality: AmuletItemQuality.Common,
      type: ItemType.Body,
      subType: BodyType.Shirt_Blue,
      health: 1,
    id: 12,
  ),
  Basic_Leather_Armour (
      quality: AmuletItemQuality.Common,
      type: ItemType.Body,
      subType: BodyType.Leather_Armour,
      health: 5,
    id: 13,
  ),
  Shoe_Leather_Boots (
      quality: AmuletItemQuality.Common,
      type: ItemType.Shoes,
      subType: ShoeType.Leather_Boots,
      health: 3,
    id: 14,
  ),
  Shoe_Iron_Plates (
      quality: AmuletItemQuality.Common,
      type: ItemType.Shoes,
      subType: ShoeType.Iron_Plates,
      health: 6,
    id: 15,
  ),
  Ocean_Boots (
      quality: AmuletItemQuality.Common,
      type: ItemType.Shoes,
      subType: ShoeType.Iron_Plates,
      health: 6,
    id: 15,
  ),
  Storm_Boots (
      quality: AmuletItemQuality.Common,
      type: ItemType.Shoes,
      subType: ShoeType.Iron_Plates,
      health: 6,
      id: 15,
  ),
  Health_Potion(
      quality: AmuletItemQuality.Common,
      type: ItemType.Consumable,
      subType: ConsumableType.Health_Potion,
      health: 10,
      consumable: true,
    id: 16,
  ),
  Treasure_Box(
    quality: AmuletItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Treasure_Box,
    collectable: false,
    experience: 3,
    id: 17,
  ),
  Meat_Drumstick(
      quality: AmuletItemQuality.Common,
      type: ItemType.Consumable,
      subType: ConsumableType.Meat_Drumstick,
      health: 4,
      collectable: false,
    id: 18,
  ),
  Lost_Pendant_Of_Dreams(
    quality: AmuletItemQuality.Mythical,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    health: 100,
    id: 19,
  ),
  Spell_Thunderbolt(
    quality: AmuletItemQuality.Mythical,
    type: ItemType.Weapon,
    subType: WeaponType.Spell_Thunderbolt,
    id: 19,
    attackType: AmuletAttackType.Lightning
  ),
  Sapphire_Pendant(
      quality: AmuletItemQuality.Rare,
      type: ItemType.Treasure,
      subType: TreasureType.Pendant_1,
      health: 5,
    id: 20,
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

  const AmuletItem({
    required this.type,
    required this.subType,
    required this.quality,
    required this.id,
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
    this.attackType
  });

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
}