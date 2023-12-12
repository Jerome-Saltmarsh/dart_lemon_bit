
import '../isometric/character_type.dart';
import '../isometric/weapon_type.dart';

enum FiendType {
  Fallen(
    health: 4,
    damage: 1,
    characterType: CharacterType.Fallen,
    attackDuration: 20,
    experience: 1,
    runSpeed: 0.7,
    chanceOfSetTarget: 0.25,
    weaponType: WeaponType.Sword,
    weaponRange: 25,
    quantity: 2,
    weaponCooldown: 20,
  ),
  Skeleton(
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
    weaponCooldown: 20,
  ),
  Wolf(
    health: 8,
    damage: 3,
    characterType: CharacterType.Wolf,
    attackDuration: 20,
    experience: 2,
    runSpeed: 1.25,
    chanceOfSetTarget: 0.3,
    weaponType: WeaponType.Unarmed,
    weaponRange: 50,
    quantity: 1,
    weaponCooldown: 20,
  );

  final int health;
  final int damage;
  final int attackDuration;
  final int characterType;
  final int experience;
  /// how many fiends are spawned per mark
  final int quantity;
  final double runSpeed;
  final double chanceOfSetTarget;
  final double weaponRange;
  final int weaponType;
  final int weaponCooldown;

  const FiendType({
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
    required this.weaponCooldown,
  });
}
