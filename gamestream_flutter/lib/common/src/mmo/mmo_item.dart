import '../../../common.dart';

enum MMOItem {
  Blink_Dagger(
    quality: MMOItemQuality.Rare,
    type: GameObjectType.Weapon,
    subType: WeaponType.Sword,
    cooldown: 40,
    range: 180,
    attackType: MMOAttackType.Blink,
    performFrame: 15,
    performDuration: 20,
  ),
  Rusty_Old_Sword(
      quality: MMOItemQuality.Common,
      type: GameObjectType.Weapon,
      subType: WeaponType.Sword,
      cooldown: 40,
      damage: 2,
      range: 80,
      attackType: MMOAttackType.Melee,
      performFrame: 20,
      performDuration: 25,
  ),
  Staff_Of_Flames(
      quality: MMOItemQuality.Unique,
      type: GameObjectType.Weapon,
      subType: WeaponType.Staff,
      cooldown: 40,
      damage: 2,
      range: 180,
      attackType: MMOAttackType.Fire_Ball,
      performFrame: 20,
      performDuration: 25,
  ),
  Staff_Of_Frozen_Lake(
      quality: MMOItemQuality.Rare,
      type: GameObjectType.Weapon,
      subType: WeaponType.Staff,
      cooldown: 40,
      damage: 2,
      range: 180,
      attackType: MMOAttackType.Freeze_Circle,
      performFrame: 20,
      performDuration: 20
  ),
  Old_Bow(
      quality: MMOItemQuality.Common,
      type: GameObjectType.Weapon,
      subType: WeaponType.Bow,
      cooldown: 40,
      damage: 1,
      range: 200,
      attackType: MMOAttackType.Arrow,
      performFrame: 20,
      performDuration: 30,
  ),
  Holy_Bow(
      quality: MMOItemQuality.Rare,
      type: GameObjectType.Weapon,
      subType: WeaponType.Bow,
      cooldown: 20,
      damage: 100,
      range: 300,
      attackType: MMOAttackType.Arrow,
      performFrame: 20,
      performDuration: 25,
  ),
  Steel_Helmet(
      quality: MMOItemQuality.Common,
      type: GameObjectType.Head,
      subType: HeadType.Steel_Helm,
      health: 10,
  ),
  Rogues_Hood(
      quality: MMOItemQuality.Unique,
      type: GameObjectType.Head,
      subType: HeadType.Rogue_Hood,
      health: 5,
      movement: 0.1,
  ),
  Ancients_Hat(
      quality: MMOItemQuality.Common,
      type: GameObjectType.Head,
      subType: HeadType.Wizards_Hat,
      health: 2,
  ),
  Travellers_Pants(
      quality: MMOItemQuality.Common,
      type: GameObjectType.Legs,
      subType: LegType.Brown,
      health: 2,
      movement: 0.1,
  ),
  Squires_Pants(
      quality: MMOItemQuality.Common,
      type: GameObjectType.Legs,
      subType: LegType.Green,
      health: 3,

  ),
  Knights_Pants(
      quality: MMOItemQuality.Unique,
      type: GameObjectType.Legs,
      subType: LegType.Blue,
      health: 5,
      movement: -0.1,
  ),
  Worn_Red_Shirt (
      quality: MMOItemQuality.Common,
      type: GameObjectType.Body,
      subType: BodyType.Shirt_Red,
      health: 2,
  ),
  Basic_Padded_Armour (
      quality: MMOItemQuality.Common,
      type: GameObjectType.Body,
      subType: BodyType.Tunic_Padded,
      health: 5,
  ),
  Squires_Armour (
      quality: MMOItemQuality.Common,
      type: GameObjectType.Body,
      subType: BodyType.Tunic_Padded,
      health: 7,
  ),
  Plated_Armour (
      quality: MMOItemQuality.Unique,
      type: GameObjectType.Body,
      subType: BodyType.Tunic_Padded,
      health: 10,
  ),
  Health_Potion(
      quality: MMOItemQuality.Common,
      type: GameObjectType.Item,
      subType: ItemType.Health_Potion,
      health: 10,
      consumable: true,
  ),
  Treasure_Box(
    quality: MMOItemQuality.Common,
    type: GameObjectType.Item,
    subType: ItemType.Treasure_Box,
    collectable: false,
    experience: 3,
  ),
  Meat_Drumstick(
      quality: MMOItemQuality.Common,
      type: GameObjectType.Item,
      subType: ItemType.Meat_Drumstick,
      health: 4,
      collectable: false,
  ),
  Lost_Pendant_Of_Dreams(
    quality: MMOItemQuality.Mythical,
    type: GameObjectType.Item,
    subType: ItemType.Pendant_1,
    health: 100,
    isTreasure: true,
  ),
  Sapphire_Pendant(
      quality: MMOItemQuality.Rare,
      type: GameObjectType.Item,
      subType: ItemType.Pendant_1,
      health: 5,
      isTreasure: true,
  );

  final int damage;
  final int type;
  final int subType;
  final int cooldown;
  final int health;
  final int experience;
  final bool collectable;
  final bool isTreasure;
  final bool consumable;
  final double range;
  final double movement;
  final MMOAttackType? attackType;
  final MMOItemQuality quality;
  final int performFrame;
  final int performDuration;

  bool get isWeapon => type == GameObjectType.Weapon;

  bool get isHead => type == GameObjectType.Head;

  bool get isBody => type == GameObjectType.Body;

  bool get isLegs => type == GameObjectType.Legs;

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
    this.isTreasure = false,
    this.consumable = false,
    this.experience = 0,
    this.performFrame = -1,
    this.performDuration = -1,
    this.attackType
  });

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
    if (performFrame > performDuration){
      validationError('performFrame cannot be greater than performDuration');
    }

    if (attackType != null && performDuration < 0){
      validationError('performDuration cannot be less than 0');
    }

    if (attackType != null && performFrame < 0){
      validationError('performFrame cannot be less than 0');
    }

    if (attackType != null && range <= 0) {
      validationError('range must be greater than 0');
    }
  }

  void validationError(String reason) =>
      print('validation_error: {name: $this, reason: $reason}');
}