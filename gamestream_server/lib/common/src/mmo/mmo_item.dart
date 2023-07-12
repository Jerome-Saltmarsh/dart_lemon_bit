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
  ),
  Health_Potion(
      type: GameObjectType.Consumable,
      subType: ConsumableType.Health_Potion,
  );

  final MMOItemQuality quality;
  final int damage;
  final int type;
  final int subType;
  final int cooldown;
  final double range;

  bool get isWeapon => type == GameObjectType.Weapon;

  bool get isHead => type == GameObjectType.Head;

  bool get isBody => type == GameObjectType.Body;

  bool get isLegs => type == GameObjectType.Legs;

  const MMOItem({
    required this.type,
    required this.subType,
    this.quality = MMOItemQuality.Normal,
    this.cooldown = 0,
    this.damage = 0,
    this.range = 0,
  });
}