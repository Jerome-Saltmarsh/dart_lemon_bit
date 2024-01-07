
import '../isometric/character_type.dart';
import '../isometric/weapon_type.dart';

enum FiendType {
  Fallen(
    level: 1,
    health: 4,
    damage: 1,
    characterType: CharacterType.Fallen,
    attackDuration: 20,
    experience: 1,
    runSpeed: 0.7,
    chanceOfSetTarget: 0.25,
    weaponType: WeaponType.Shortsword,
    weaponRange: 25,
    quantity: 2,
    weaponCooldown: 20,
    clearTargetOnPerformAction: true,
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
    weaponCooldown: 20,
    clearTargetOnPerformAction: true,
  ),
  Wolf(
    level: 3,
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
    clearTargetOnPerformAction: false,
  ),
  Zombie(
    level: 4,
    health: 12,
    damage: 3,
    characterType: CharacterType.Zombie,
    attackDuration: 20,
    experience: 2,
    runSpeed: 0.5,
    chanceOfSetTarget: 0.3,
    weaponType: WeaponType.Unarmed,
    weaponRange: 50,
    quantity: 1,
    weaponCooldown: 20,
    clearTargetOnPerformAction: true,
  ),
  Fallen_Armoured(
    level: 5,
    health: 12,
    damage: 3,
    characterType: CharacterType.Fallen_Armoured,
    attackDuration: 20,
    experience: 3,
    runSpeed: 0.7,
    chanceOfSetTarget: 0.35,
    weaponType: WeaponType.Shortsword,
    weaponRange: 25,
    quantity: 2,
    weaponCooldown: 20,
    clearTargetOnPerformAction: true,
  ),
  Gargoyle(
    level: 6,
    health: 30,
    damage: 4,
    characterType: CharacterType.Gargoyle_01,
    attackDuration: 20,
    experience: 8,
    runSpeed: 0.7,
    chanceOfSetTarget: 0.5,
    weaponType: WeaponType.Shortsword,
    weaponRange: 120,
    quantity: 2,
    weaponCooldown: 30,
    clearTargetOnPerformAction: false,
  );

  final int level;
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
  final bool clearTargetOnPerformAction;

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
    required this.level,
    required this.clearTargetOnPerformAction,
  });
}
