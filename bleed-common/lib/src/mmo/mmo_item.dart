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
      damage: 2,
      range: 80,
  );

  final MMOItemQuality quality;
  final int damage;
  final int type;
  final int subType;
  final int cooldown;
  final double range;

  const MMOItem({
    required this.quality,
    required this.type,
    required this.subType,
    this.cooldown = 0,
    this.damage = 0,
    this.range = 0,
  });
}