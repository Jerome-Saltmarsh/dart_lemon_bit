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
  Ancients_Hat(
      type: GameObjectType.Head,
      subType: HeadType.Wizards_Hat,
      quality: MMOItemQuality.Magic,
      health: 5,
  ),
  Health_Potion(
      type: GameObjectType.Consumable,
      subType: ConsumableType.Health_Potion,
      health: 10,
  );

  final MMOItemQuality? quality;
  final int damage;
  final int type;
  final int subType;
  final int cooldown;
  final int health;
  final double range;

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
  });
}