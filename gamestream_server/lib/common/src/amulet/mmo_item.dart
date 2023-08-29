
import '../../src.dart';
import '../isometric/treasure_type.dart';


enum MMOItem {
  Blink_Dagger(
    quality: MMOItemQuality.Rare,
    type: ItemType.Weapon,
    subType: WeaponType.Sword,
    cooldown: 40,
    range: 180,
    attackType: MMOAttackType.Blink,
    actionFrame: 15,
    performDuration: 20,
  ),
  Rusty_Old_Sword(
      quality: MMOItemQuality.Common,
      type: ItemType.Weapon,
      subType: WeaponType.Sword,
      cooldown: 40,
      damage: 2,
      range: 80,
      attackType: MMOAttackType.Melee,
      actionFrame: 20,
      performDuration: 25,
  ),
  Staff_Of_Flames(
      quality: MMOItemQuality.Unique,
      type: ItemType.Weapon,
      subType: WeaponType.Staff,
      cooldown: 40,
      damage: 2,
      range: 180,
      attackType: MMOAttackType.Fire_Ball,
      actionFrame: 20,
      performDuration: 25,
  ),
  Staff_Of_Frozen_Lake(
      quality: MMOItemQuality.Rare,
      type: ItemType.Weapon,
      subType: WeaponType.Staff,
      cooldown: 40,
      damage: 2,
      range: 180,
      attackType: MMOAttackType.Frost_Ball,
      actionFrame: 15,
      performDuration: 20
  ),
  Old_Bow(
      quality: MMOItemQuality.Common,
      type: ItemType.Weapon,
      subType: WeaponType.Bow,
      cooldown: 40,
      damage: 1,
      range: 200,
      attackType: MMOAttackType.Arrow,
      actionFrame: 20,
      performDuration: 30,
  ),
  Holy_Bow(
      quality: MMOItemQuality.Rare,
      type: ItemType.Weapon,
      subType: WeaponType.Bow,
      cooldown: 20,
      damage: 100,
      range: 300,
      attackType: MMOAttackType.Arrow,
      actionFrame: 12,
      performDuration: 25,
  ),
  Steel_Helmet(
      quality: MMOItemQuality.Common,
      type: ItemType.Helm,
      subType: HelmType.Steel,
      health: 10,
  ),
  Wizards_Hat(
      quality: MMOItemQuality.Common,
      type: ItemType.Helm,
      subType: HelmType.Wizard_Hat,
      health: 10,
  ),
  Travellers_Pants(
      quality: MMOItemQuality.Common,
      type: ItemType.Legs,
      subType: LegType.Brown,
      health: 2,
      movement: 0.1,
  ),
  Gauntlet(
      quality: MMOItemQuality.Common,
      type: ItemType.Hand,
      subType: HandType.Gauntlets,
      health: 2,
  ),
  Squires_Pants(
      quality: MMOItemQuality.Common,
      type: ItemType.Legs,
      subType: LegType.Green,
      health: 3,
  ),
  Knights_Pants(
      quality: MMOItemQuality.Unique,
      type: ItemType.Legs,
      subType: LegType.Blue,
      health: 5,
      movement: -0.1,
  ),
  Worn_Red_Shirt (
      quality: MMOItemQuality.Common,
      type: ItemType.Body,
      subType: BodyType.Shirt_Red,
      health: 1,
  ),
  Worn_Shirt_Blue (
      quality: MMOItemQuality.Common,
      type: ItemType.Body,
      subType: BodyType.Shirt_Blue,
      health: 1,
  ),
  Basic_Padded_Armour (
      quality: MMOItemQuality.Common,
      type: ItemType.Body,
      subType: BodyType.Tunic_Padded,
      health: 5,
  ),
  Squires_Armour (
      quality: MMOItemQuality.Common,
      type: ItemType.Body,
      subType: BodyType.Tunic_Padded,
      health: 7,
  ),
  Plated_Armour (
      quality: MMOItemQuality.Unique,
      type: ItemType.Body,
      subType: BodyType.Tunic_Padded,
      health: 10,
  ),
  Health_Potion(
      quality: MMOItemQuality.Common,
      type: ItemType.Consumable,
      subType: ConsumableType.Health_Potion,
      health: 10,
      consumable: true,
  ),
  Treasure_Box(
    quality: MMOItemQuality.Common,
    type: ItemType.Consumable,
    subType: ConsumableType.Treasure_Box,
    collectable: false,
    experience: 3,
  ),
  Meat_Drumstick(
      quality: MMOItemQuality.Common,
      type: ItemType.Consumable,
      subType: ConsumableType.Meat_Drumstick,
      health: 4,
      collectable: false,
  ),
  Lost_Pendant_Of_Dreams(
    quality: MMOItemQuality.Mythical,
    type: ItemType.Treasure,
    subType: TreasureType.Pendant_1,
    health: 100,
  ),
  Sapphire_Pendant(
      quality: MMOItemQuality.Rare,
      type: ItemType.Treasure,
      subType: TreasureType.Pendant_1,
      health: 5,
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
  final MMOAttackType? attackType;
  final MMOItemQuality quality;
  final int actionFrame;
  final int performDuration;

  const MMOItem({
    required this.type,
    required this.subType,
    required this.quality,
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

  bool get isHelm => type == ItemType.Helm;

  bool get isHand => type == ItemType.Hand;

  bool get isConsumable => type == ItemType.Consumable;

  bool get isBody => type == ItemType.Body;

  bool get isLegs => type == ItemType.Legs;

  bool get isTreasure => type == ItemType.Treasure;

  static final valuesCommon = _findByQuality(MMOItemQuality.Common);
  static final valuesUnique = _findByQuality(MMOItemQuality.Unique);
  static final valuesRare = _findByQuality(MMOItemQuality.Rare);
  static final valuesMythical = _findByQuality(MMOItemQuality.Mythical);

  static List<MMOItem> _findByQuality(MMOItemQuality quality) =>
      values.where((item) => item.quality == quality).toList(growable: false);

  static List<MMOItem> findByQuality(MMOItemQuality quality) =>
        switch (quality) {
          MMOItemQuality.Common => valuesCommon,
          MMOItemQuality.Unique => valuesUnique,
          MMOItemQuality.Rare => valuesRare,
          MMOItemQuality.Mythical => valuesMythical,
        };

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