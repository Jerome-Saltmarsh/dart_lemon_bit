
import 'package:amulet_engine/isometric/enums/damage_type.dart';
import 'package:amulet_engine/src.dart';
import 'package:lemon_lang/src.dart';

enum FiendType {
  Goblin(
    level: 1,
    health: 4,
    damage: 2,
    characterType: CharacterType.Fallen,
    attackDuration: 20,
    runSpeed: 0.7,
    chanceOfSetTarget: 0.25,
    weaponRange: 60,
    quantity: 2,
    clearTargetOnPerformAction: true,
    postAttackPauseDurationMin: 20,
    postAttackPauseDurationMax: 50,
    chanceOfDropCommon: 0.25,
    chanceOfDropRare: 0.05,
    chanceOfDropLegendary: 0.01,
    chanceOfDropPotion: 0.15,
    skillType: SkillType.Strike,
    skillLevel: 1,
  ),
  Wolf(
    level: 2,
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
    skillTypeB: SkillType.Blind,
    skillLevel: 1,
  ),
  Skeleton(
    level: 3,
    health: 10,
    damage: 6,
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
    skillLevel: 1,
  ),
  Zombie(
    level: 4,
    health: 19,
    damage: 10,
    areaDamage: 3,
    characterType: CharacterType.Zombie,
    attackDuration: 25,
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
    skillLevel: 1,
    healthSteal: 0.1,
  ),
  Goblin_Armoured(
    level: 5,
    health: 27,
    damage: 9,
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
    skillLevel: 1,
  ),
  Gargoyle(
    level: 6,
    health: 34,
    damage: 7,
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
    skillLevel: 1,
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
  final int skillLevel;
  final bool clearTargetOnPerformAction;
  final int postAttackPauseDurationMin;
  final int postAttackPauseDurationMax;
  final double chanceOfDropLegendary;
  final double chanceOfDropRare;
  final double chanceOfDropCommon;
  final double chanceOfDropPotion;
  final DamageType? resists;
  final SkillType skillType;
  final SkillType? skillTypeB;
  final double areaDamage;
  final double healthSteal;

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
    required this.skillLevel,
    this.skillTypeB,
    this.resists,
    this.areaDamage = 0,
    this.healthSteal = 0,
  });

  int get quantify {
    var total = 0;
    total += health;
    total += ((damage / attackDuration) * 45).toInt();
    total += weaponRange ~/ 30;
    if (resists != null) {
      total += 3;
    }
    return total;
  }

  static final sortedValues = (){
    return List.of(values).sortBy((f) => f.level);
  }();

  static int sortByLevel(FiendType a, FiendType b){
    final aQuantify = a.level;
    final bQuantify = b.level;
    if (aQuantify < bQuantify){
      return -1;
    }
    if (aQuantify > bQuantify){
      return 1;
    }
    return 0;
  }

}



