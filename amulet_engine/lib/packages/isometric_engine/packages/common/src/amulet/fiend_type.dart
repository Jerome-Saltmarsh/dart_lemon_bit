
import '../../../../enums/damage_type.dart';
import '../isometric/character_type.dart';
import 'skill_type.dart';

enum FiendType {
  Goblin(
    level: 1,
    health: 4,
    damage: 2,
    characterType: CharacterType.Fallen,
    attackDuration: 20,
    runSpeed: 0.7,
    chanceOfSetTarget: 0.25,
    weaponRange: 50,
    quantity: 2,
    clearTargetOnPerformAction: true,
    postAttackPauseDurationMin: 20,
    postAttackPauseDurationMax: 50,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.01,
    chanceOfDropPotion: 0.15,
    skillType: SkillType.Strike,
  ),
  Skeleton(
    level: 2,
    health: 6,
    damage: 3,
    characterType: CharacterType.Skeleton,
    attackDuration: 20,
    runSpeed: 1.0,
    chanceOfSetTarget: 0.3,
    weaponRange: 150,
    quantity: 2,
    clearTargetOnPerformAction: false,
    postAttackPauseDurationMin: 30,
    postAttackPauseDurationMax: 80,
    resists: DamageType.Fire,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.025,
    chanceOfDropPotion: 0.15,
    skillType: SkillType.Shoot_Arrow,
  ),
  Wolf(
    level: 3,
    health: 10,
    damage: 3,
    characterType: CharacterType.Wolf,
    attackDuration: 20,
    runSpeed: 1.25,
    chanceOfSetTarget: 0.3,
    weaponRange: 50,
    quantity: 1,
    clearTargetOnPerformAction: false,
    postAttackPauseDurationMin: 20,
    postAttackPauseDurationMax: 40,
    resists: DamageType.Ice,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.025,
    chanceOfDropPotion: 0.15,
    skillType: SkillType.Strike,
  ),
  Zombie(
    level: 4,
    health: 20,
    damage: 10,
    characterType: CharacterType.Zombie,
    attackDuration: 20,
    runSpeed: 0.5,
    chanceOfSetTarget: 0.3,
    weaponRange: 50,
    quantity: 1,
    clearTargetOnPerformAction: true,
    postAttackPauseDurationMin: 20,
    postAttackPauseDurationMax: 60,
    resists: DamageType.Melee,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.025,
    chanceOfDropPotion: 0.15,
    skillType: SkillType.Strike,
  ),
  Fallen_Armoured(
    level: 5,
    health: 12,
    damage: 3,
    characterType: CharacterType.Fallen_Armoured,
    attackDuration: 20,
    runSpeed: 0.7,
    chanceOfSetTarget: 0.35,
    weaponRange: 25,
    quantity: 2,
    clearTargetOnPerformAction: true,
    postAttackPauseDurationMin: 20,
    postAttackPauseDurationMax: 50,
    resists: DamageType.Melee,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.025,
    chanceOfDropPotion: 0.15,
    skillType: SkillType.Strike,
  ),
  Gargoyle(
    level: 6,
    health: 30,
    damage: 4,
    characterType: CharacterType.Gargoyle_01,
    attackDuration: 20,
    runSpeed: 0.65,
    chanceOfSetTarget: 0.5,
    weaponRange: 130,
    quantity: 1,
    clearTargetOnPerformAction: false,
    postAttackPauseDurationMin: 30,
    postAttackPauseDurationMax: 100,
    resists: DamageType.Pierce,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.025,
    chanceOfDropPotion: 0.15,
    skillType: SkillType.Fireball,
  ),
  Toad_Warrior(
    level: 6,
    health: 20,
    damage: 4,
    characterType: CharacterType.Toad_Warrior,
    attackDuration: 20,
    runSpeed: 0.65,
    chanceOfSetTarget: 0.5,
    weaponRange: 130,
    quantity: 1,
    clearTargetOnPerformAction: false,
    postAttackPauseDurationMin: 30,
    postAttackPauseDurationMax: 100,
    resists: DamageType.Melee,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.025,
    chanceOfDropPotion: 0.15,
    skillType: SkillType.Strike,
  );

  final int level;
  final int health;
  final int damage;
  final int attackDuration;
  final int characterType;
  /// how many fiends are spawned per mark
  final int quantity;
  final double runSpeed;
  final double chanceOfSetTarget;
  final double weaponRange;
  final double skillRadius;
  final bool clearTargetOnPerformAction;
  final int postAttackPauseDurationMin;
  final int postAttackPauseDurationMax;
  final double chanceOfDropLegendary;
  final double chanceOfDropRare;
  final double chanceOfDropCommon;
  final double chanceOfDropPotion;
  final DamageType? resists;
  final SkillType skillType;

  const FiendType({
    required this.health,
    required this.damage,
    required this.characterType,
    required this.attackDuration,
    required this.runSpeed,
    required this.chanceOfSetTarget,
    required this.weaponRange,
    required this.quantity,
    required this.level,
    required this.clearTargetOnPerformAction,
    required this.postAttackPauseDurationMin,
    required this.postAttackPauseDurationMax,
    required this.chanceOfDropCommon,
    required this.chanceOfDropRare,
    required this.chanceOfDropLegendary,
    required this.chanceOfDropPotion,
    required this.skillType,
    this.resists,
    this.skillRadius = 0,
  });

  int get quantify {
    var total = 0;
    total += health;
    total += ((damage / attackDuration) * 45).toInt();
    total += skillType.quantify;
    if (resists != null) {
      total += 3;
    }
    return total;
  }

  static final sortedValues = (){
    final vals = List.of(values);
    vals.sort(sortByQuantify);
    return vals;
  }();

  static int sortByQuantify(FiendType a, FiendType b){
    final aQuantify = a.quantify;
    final bQuantify = b.quantify;
    if (aQuantify < bQuantify){
      return -1;
    }
    if (aQuantify > bQuantify){
      return 1;
    }
    return 0;
  }
}



