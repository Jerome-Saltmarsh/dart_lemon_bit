
import 'package:amulet_common/src.dart';
import 'package:amulet_common/src/isometric/damage_type.dart';

enum FiendType {
  Goblin(
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
    skillType: SkillType.Slash,
    skillTypes: {

    }
  ),
  Wolf(
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
    skillType: SkillType.Slash,
    pierceResistance: 0.25,
    fireResistance: 0.25,
      skillTypes: {
        SkillType.Shield: 2,
      }
  ),
  Skeleton(
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
    skillType: SkillType.Shoot_Arrow,
    fireResistance: 0.25,
      skillTypes: {

      }
  ),
  Zombie(
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
    skillType: SkillType.Slash,
    healthSteal: 0.1,
    iceResistance: 0.25,
    skillTypes: {

    }
  ),
  Goblin_Armoured(
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
    skillType: SkillType.Slash,
    chanceOfCriticalDamage: 3,
      skillTypes: {

      }
  ),
  Gargoyle(
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
    skillType: SkillType.Fireball,
    meleeResistance: 0.25,
    skillTypes: {

    }
  );

  final double health;
  final double damage;
  final int attackDuration;
  final int characterType;
  /// how many fiends are spawned per mark
  final int quantity;
  final double runSpeed;
  final double chanceOfSetTarget;
  /// between 0.0 and 1.0
  final double weaponRange;
  final bool clearTargetOnPerformAction;
  final int postAttackPauseDurationMin;
  final int postAttackPauseDurationMax;
  final SkillType skillType;
  final SkillType? skillTypeB;
  final double areaDamage;
  final double healthSteal;
  final double chanceOfCriticalDamage;
  /// value between 0.0 and 1.0
  final double meleeResistance;
  final double fireResistance;
  final double iceResistance;
  final double pierceResistance;
  final Map<SkillType, int> skillTypes;

  const FiendType({
    required this.health,
    required this.damage,
    required this.characterType,
    required this.attackDuration,
    required this.runSpeed,
    required this.chanceOfSetTarget,
    required this.weaponRange,
    required this.quantity,
    required this.clearTargetOnPerformAction,
    required this.postAttackPauseDurationMin,
    required this.postAttackPauseDurationMax,
    required this.skillType,
    required this.skillTypes,
    this.chanceOfCriticalDamage = 0,
    this.skillTypeB,
    this.areaDamage = 0,
    this.healthSteal = 0,
    this.fireResistance = 0,
    this.iceResistance = 0,
    this.pierceResistance = 0,
    this.meleeResistance = 0,
  });

  double get quantify {
    var total = 0.0;
    total += health;
    total += damage;

    final attackRatio = attackDuration / 50;
    final rangeRatio = weaponRange / 100;

    total *= rangeRatio;
    total *= runSpeed;
    total *= attackRatio;


    return total;
  }

  // static final sortedValues = (){
  //   return List.of(values).sortBy((f) => f.level);
  // }();

  // static int sortByLevel(FiendType a, FiendType b){
  //   final aQuantify = a.level;
  //   final bQuantify = b.level;
  //   if (aQuantify < bQuantify){
  //     return -1;
  //   }
  //   if (aQuantify > bQuantify){
  //     return 1;
  //   }
  //   return 0;
  // }

  double getDamageTypeResistance(DamageType damageType) =>
      switch (damageType) {
        DamageType.Bludgeon => meleeResistance,
        DamageType.Pierce => pierceResistance,
        DamageType.Fire => fireResistance,
        DamageType.Ice => iceResistance,
        DamageType.Slash => 0,
      };
}



