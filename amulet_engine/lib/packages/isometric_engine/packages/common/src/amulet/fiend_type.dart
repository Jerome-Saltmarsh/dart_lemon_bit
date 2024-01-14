
import '../../../../enums/damage_type.dart';
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
    postAttackPauseDurationMin: 20,
    postAttackPauseDurationMax: 50,
    elementFire: 1,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.025,
    chanceOfDropPotion: 0.15,
  ),
  Skeleton(
    level: 2,
    health: 5,
    damage: 1,
    characterType: CharacterType.Skeleton,
    attackDuration: 20,
    experience: 2,
    runSpeed: 1.0,
    chanceOfSetTarget: 0.3,
    weaponType: WeaponType.Bow,
    weaponRange: 150,
    quantity: 2,
    weaponCooldown: 20,
    clearTargetOnPerformAction: false,
    postAttackPauseDurationMin: 30,
    postAttackPauseDurationMax: 80,
    elementStone: 1,
    resists: DamageType.fire,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.025,
    chanceOfDropPotion: 0.15,
  ),
  Wolf(
    level: 3,
    health: 10,
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
    postAttackPauseDurationMin: 20,
    postAttackPauseDurationMax: 40,
    elementAir: 1,
    resists: DamageType.wind,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.025,
    chanceOfDropPotion: 0.15,
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
    postAttackPauseDurationMin: 20,
    postAttackPauseDurationMax: 60,
    elementWater: 1,
    resists: DamageType.melee,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.025,
    chanceOfDropPotion: 0.15,
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
    postAttackPauseDurationMin: 20,
    postAttackPauseDurationMax: 50,
    elementWater: 1,
    resists: DamageType.melee,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.025,
    chanceOfDropPotion: 0.15,
  ),
  Gargoyle(
    level: 6,
    health: 30,
    damage: 4,
    characterType: CharacterType.Gargoyle_01,
    attackDuration: 20,
    experience: 8,
    runSpeed: 0.65,
    chanceOfSetTarget: 0.5,
    weaponType: WeaponType.Shortsword,
    weaponRange: 130,
    quantity: 1,
    weaponCooldown: 30,
    clearTargetOnPerformAction: false,
    postAttackPauseDurationMin: 30,
    postAttackPauseDurationMax: 100,
    elementStone: 1,
    resists: DamageType.projectile,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.025,
    chanceOfDropPotion: 0.15,
  ),
  Toad_Warrior(
    level: 6,
    health: 20,
    damage: 4,
    characterType: CharacterType.Toad_Warrior,
    attackDuration: 20,
    experience: 8,
    runSpeed: 0.65,
    chanceOfSetTarget: 0.5,
    weaponType: WeaponType.Shortsword,
    weaponRange: 130,
    quantity: 1,
    weaponCooldown: 30,
    clearTargetOnPerformAction: false,
    postAttackPauseDurationMin: 30,
    postAttackPauseDurationMax: 100,
    elementWater: 1,
    resists: DamageType.melee,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.025,
    chanceOfDropPotion: 0.15,
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
  final int postAttackPauseDurationMin;
  final int postAttackPauseDurationMax;
  final int elementWater;
  final int elementFire;
  final int elementAir;
  final int elementStone;
  final double chanceOfDropLegendary;
  final double chanceOfDropRare;
  final double chanceOfDropCommon;
  final double chanceOfDropPotion;
  final DamageType? resists;

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
    required this.postAttackPauseDurationMin,
    required this.postAttackPauseDurationMax,
    required this.chanceOfDropCommon,
    required this.chanceOfDropRare,
    required this.chanceOfDropLegendary,
    required this.chanceOfDropPotion,
    this.resists,
    this.elementWater = 0,
    this.elementFire = 0,
    this.elementAir = 0,
    this.elementStone = 0,
  });
}
