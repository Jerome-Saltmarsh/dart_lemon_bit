import '../isometric/src.dart';
import 'mmo_item_quality.dart';

enum MMOItem {
  Rusty_Old_Sword(
      type: GameObjectType.Weapon,
      subType: WeaponType.Sword,
      quality: MMOItemQuality.Low,
      cooldown: 40,
      damage: 2,
      range: 80,
  ),
  Old_Bow(
      type: GameObjectType.Weapon,
      subType: WeaponType.Bow,
      quality: MMOItemQuality.Low,
      cooldown: 40,
      damage: 1,
      range: 200,
  ),
  Steel_Helmet(
      type: GameObjectType.Head,
      subType: HeadType.Steel_Helm,
      quality: MMOItemQuality.Normal,
      health: 10,
  ),
  Rogues_Hood(
      type: GameObjectType.Head,
      subType: HeadType.Rogue_Hood,
      quality: MMOItemQuality.Normal,
      health: 5,
      movement: 0.1,
  ),
  Ancients_Hat(
      type: GameObjectType.Head,
      subType: HeadType.Wizards_Hat,
      quality: MMOItemQuality.Magic,
      health: 2,
  ),
  Travellers_Pants(
      type: GameObjectType.Legs,
      subType: LegType.Brown,
      quality: MMOItemQuality.Normal,
      health: 2,
      movement: 0.1,
  ),
  Squires_Pants(
      type: GameObjectType.Legs,
      subType: LegType.Green,
      quality: MMOItemQuality.Normal,
      health: 3,
  ),
  Knights_Pants(
      type: GameObjectType.Legs,
      subType: LegType.Blue,
      quality: MMOItemQuality.Normal,
      health: 5,
      movement: -0.1,
  ),
  Worn_Red_Shirt (
      type: GameObjectType.Body,
      subType: BodyType.Shirt_Red,
      quality: MMOItemQuality.Normal,
      health: 2,
  ),
  Basic_Padded_Armour (
      type: GameObjectType.Body,
      subType: BodyType.Tunic_Padded,
      quality: MMOItemQuality.Normal,
      health: 5,
  ),
  Squires_Armour (
      type: GameObjectType.Body,
      subType: BodyType.Tunic_Padded,
      quality: MMOItemQuality.Normal,
      health: 7,
  ),
  Plated_Armour (
      type: GameObjectType.Body,
      subType: BodyType.Tunic_Padded,
      quality: MMOItemQuality.Normal,
      health: 10,
  ),
  Health_Potion(
      type: GameObjectType.Item,
      subType: ItemType.Health_Potion,
      health: 10,
  ),
  Meat_Drumstick(
      type: GameObjectType.Item,
      subType: ItemType.Meat_Drumstick,
      health: 4,
      collectable: false,
  );


  final MMOItemQuality? quality;
  final int damage;
  final int type;
  final int subType;
  final int cooldown;
  final int health;
  final bool collectable;
  final double range;
  final double movement;

  bool get isWeapon => type == GameObjectType.Weapon;

  bool get isHead => type == GameObjectType.Head;

  bool get isBody => type == GameObjectType.Body;

  bool get isLegs => type == GameObjectType.Legs;

  const MMOItem({
    required this.type,
    required this.subType,
    this.quality,
    this.cooldown = 0,
    this.damage = 0,
    this.range = 0,
    this.health = 0,
    this.collectable = true,
    this.movement = 0,
  });
}