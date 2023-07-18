import '../isometric/src.dart';
import 'mmo_attack_type.dart';

enum MMOItem {
  Rusty_Old_Sword(
      type: GameObjectType.Weapon,
      subType: WeaponType.Sword,
      cooldown: 40,
      damage: 2,
      range: 80,
      attackType: MMOAttackType.Melee,
  ),
  Staff_Of_Flames(
      type: GameObjectType.Weapon,
      subType: WeaponType.Staff,
      cooldown: 40,
      damage: 2,
      range: 180,
      attackType: MMOAttackType.Fire_Ball,
  ),
  Old_Bow(
      type: GameObjectType.Weapon,
      subType: WeaponType.Bow,
      cooldown: 40,
      damage: 1,
      range: 200,
      attackType: MMOAttackType.Arrow,
  ),
  Holy_Bow(
      type: GameObjectType.Weapon,
      subType: WeaponType.Bow,
      cooldown: 20,
      damage: 100,
      range: 300,
      attackType: MMOAttackType.Arrow,
  ),
  Steel_Helmet(
      type: GameObjectType.Head,
      subType: HeadType.Steel_Helm,
      health: 10,
  ),
  Rogues_Hood(
      type: GameObjectType.Head,
      subType: HeadType.Rogue_Hood,
      health: 5,
      movement: 0.1,
  ),
  Ancients_Hat(
      type: GameObjectType.Head,
      subType: HeadType.Wizards_Hat,
      health: 2,
  ),
  Travellers_Pants(
      type: GameObjectType.Legs,
      subType: LegType.Brown,
      health: 2,
      movement: 0.1,
  ),
  Squires_Pants(
      type: GameObjectType.Legs,
      subType: LegType.Green,
      health: 3,
  ),
  Knights_Pants(
      type: GameObjectType.Legs,
      subType: LegType.Blue,
      health: 5,
      movement: -0.1,
  ),
  Worn_Red_Shirt (
      type: GameObjectType.Body,
      subType: BodyType.Shirt_Red,
      health: 2,
  ),
  Basic_Padded_Armour (
      type: GameObjectType.Body,
      subType: BodyType.Tunic_Padded,
      health: 5,
  ),
  Squires_Armour (
      type: GameObjectType.Body,
      subType: BodyType.Tunic_Padded,
      health: 7,
  ),
  Plated_Armour (
      type: GameObjectType.Body,
      subType: BodyType.Tunic_Padded,
      health: 10,
  ),
  Health_Potion(
      type: GameObjectType.Item,
      subType: ItemType.Health_Potion,
      health: 10,
      consumable: true,
  ),
  Meat_Drumstick(
      type: GameObjectType.Item,
      subType: ItemType.Meat_Drumstick,
      health: 4,
      collectable: false,
  ),
  Sapphire_Pendant(
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
  final bool collectable;
  final bool isTreasure;
  final bool consumable;
  final double range;
  final double movement;
  final MMOAttackType? attackType;

  bool get isWeapon => type == GameObjectType.Weapon;

  bool get isHead => type == GameObjectType.Head;

  bool get isBody => type == GameObjectType.Body;

  bool get isLegs => type == GameObjectType.Legs;

  const MMOItem({
    required this.type,
    required this.subType,
    this.cooldown = 0,
    this.damage = 0,
    this.range = 0,
    this.health = 0,
    this.collectable = true,
    this.movement = 0,
    this.isTreasure = false,
    this.consumable = false,
    this.attackType
  });
}