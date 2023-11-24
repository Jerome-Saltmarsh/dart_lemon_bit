
import '../isometric/character_type.dart';
import '../isometric/weapon_type.dart';

enum FiendType {
  Fallen(
    level: 1,
    health: 3,
    damage: 1,
    characterType: CharacterType.Fallen,
    attackDuration: 20,
    experience: 1,
    runSpeed: 0.8,
    chanceOfSetTarget: 0.25,
    weaponType: WeaponType.Sword,
    weaponRange: 25,
    quantity: 3,
  ),
  Skeleton(
    level: 2,
    health: 5,
    damage: 1,
    characterType: CharacterType.Skeleton,
    attackDuration: 20,
    experience: 2,
    runSpeed: 1.0,
    chanceOfSetTarget: 0.25,
    weaponType: WeaponType.Bow,
    weaponRange: 150,
    quantity: 2,
  );

  final int level;
  final int health;
  final int damage;
  final int attackDuration;
  final int characterType;
  final int weaponType;
  final int experience;
  /// how many fiends are spawned per mark
  final int quantity;
  final double runSpeed;
  final double chanceOfSetTarget;
  final double weaponRange;

  const FiendType({
    required this.level,
    required this.health,
    required this.damage,
    required this.characterType,
    required this.attackDuration,
    required this.experience,
    required this.runSpeed,
    required this.chanceOfSetTarget,
    required this.weaponType,
    required this.weaponRange,
    required this.quantity,
  });
}
