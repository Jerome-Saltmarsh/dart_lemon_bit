
import 'package:amulet_common/src.dart';
import 'package:lemon_math/src.dart';

enum SkillType {
  None(
      casteType: CasteType.Passive,
      range: 0,
      maxLevel: 0,
  ),
  Slash(
      damageMin: Constraint(min: 1, max: 20),
      damageMax: Constraint(min: 1, max: 20),
      casteType: CasteType.Ability,
      magicCost: 0,
      isBaseAttack: true,
      enabledBow: false,
      enabledSword: true,
      enabledStaff: false,
  ),
  Bludgeon(
      damageMin: Constraint(min: 1, max: 20),
      damageMax: Constraint(min: 1, max: 20),
      casteType: CasteType.Ability,
      magicCost: 0,
      isBaseAttack: true,
      enabledBow: false,
      enabledSword: false,
      enabledStaff: true,
  ),
  Mighty_Strike(
      casteType: CasteType.Ability,
      magicCost: 3,
      enabledBow: false,
      enabledSword: true,
      enabledStaff: false,
  ),
  Ice_Ball(
      casteType: CasteType.Ability,
      magicCost: 4,
      enabledBow: false,
      enabledSword: true,
      enabledStaff: true,
      enabledUnarmed: true,
  ),
  Fire_Ball(
      casteType: CasteType.Ability,
      magicCost: 5,
      enabledBow: false,
      enabledSword: true,
      enabledStaff: true,
      enabledUnarmed: true,
  ),
  Explode(
      casteType: CasteType.Ability,
      magicCost: 7,
      enabledBow: false,
      enabledSword: true,
      enabledStaff: true,
      enabledUnarmed: true,
  ),
  // BOW
  Shoot_Arrow(
      damageMin: Constraint(min: 1, max: 20),
      damageMax: Constraint(min: 1, max: 20),
      casteType: CasteType.Ability,
      magicCost: 0,
      isBaseAttack: true,
      enabledBow: true,
      enabledSword: false,
      enabledStaff: false,
  ),
  Split_Shot(
    casteType: CasteType.Ability,
    magicCost: 4,
    enabledBow: true,
    enabledSword: false,
    enabledStaff: false,
  ),
  Ice_Arrow(
    casteType: CasteType.Ability,
    magicCost: 4,
    enabledBow: true,
    enabledSword: false,
    enabledStaff: false,
  ),
  Fire_Arrow(
    casteType: CasteType.Ability,
    magicCost: 4,
    enabledBow: true,
    enabledSword: false,
    enabledStaff: false,
  ),
  Heal(
      casteType: CasteType.Ability,
      magicCost: 4,
      range: 0,
      isCaste: true,
      enabledUnarmed: true,
  ),
  Max_Health(
    casteType: CasteType.Passive,
  ),
  Max_Magic(
    casteType: CasteType.Passive,
  ),
  Attack_Speed(
    casteType: CasteType.Passive,
    maxLevel: 10,
  ),
  Health_Steal(
    casteType: CasteType.Passive,
  ),
  Magic_Steal(
    casteType: CasteType.Passive,
  ),
  Critical_Hit(
    casteType: CasteType.Passive,
  ),
  Magic_Regen(
    casteType: CasteType.Passive,
  ),
  Health_Regen(
    casteType: CasteType.Passive,
  ),
  Area_Damage(
    casteType: CasteType.Passive,
  ),
  Run_Speed(
    casteType: CasteType.Passive,
    constraint: Constraint(min: 0, max: 3.0),
  ),
  Resist_Pierce(
    casteType: CasteType.Passive,
    constraint: Constraint_Resist,
  ),
  Resist_Slash(
    casteType: CasteType.Passive,
    constraint: Constraint_Resist,
  ),
  Resist_Fire(
    casteType: CasteType.Passive,
    constraint: Constraint_Resist,
  ),
  Resist_Ice(
    casteType: CasteType.Passive,
    constraint: Constraint_Resist,
  ),
  Resist_Bludgeon(
    casteType: CasteType.Passive,
    constraint: Constraint_Resist,
  ),
  Attack_Range(
    casteType: CasteType.Passive,
    maxLevel: 10,
  ),
  Wind_Cut(
    casteType: CasteType.Ability,
    maxLevel: 20,
  ),
  ;


  final int maxLevel;
  final CasteType casteType;
  final bool enabledBow;
  final bool enabledSword;
  final bool enabledStaff;
  final bool enabledUnarmed;
  final int magicCost;
  final Constraint? constraint;
  /// if null the weapon perform duration is used
  /// if null the weapon range is used
  final double? range;
  final bool isBaseAttack;
  final Constraint? damageMin; 
  final Constraint? damageMax;
  final bool isCaste;

  static const Constraint_Health_Steal = Constraint(min: 0, max: 0.5);
  static const Constraint_Magic_Steal = Constraint(min: 0, max: 0.5);
  static const Constraint_Critical_Hit = Constraint(min: 0, max: 0.5);
  static const Constraint_Might_Swing = Constraint(min: 0.0, max: 3.0);
  static const Constraint_Run_Speed = Constraint(min: 0.0, max: 4.0);

  static const Constraint_Damage_Ice_Arrow = Constraint(min: 0.0, max: 80.0);
  static const Constraint_Damage_Ice_Ball = Constraint(min: 0.0, max: 100.0);
  static const Constraint_Damage_Fire_Arrow = Constraint(min: 0.0, max: 120.0);
  static const Constraint_Damage_Fire_Ball = Constraint(min: 0.0, max: 150.0);
  static const Constraint_Damage_Explode = Constraint(min: 0.0, max: 200.0);

  static const Constraint_Ailment_Damage_Ice_Arrow = Constraint(min: 0.0, max: 5.0);
  static const Constraint_Ailment_Damage_Ice_Ball = Constraint(min: 0.0, max: 5.0);
  static const Constraint_Ailment_Damage_Fire_Arrow = Constraint(min: 0.0, max: 5.0);
  static const Constraint_Ailment_Damage_Fire_Ball = Constraint(min: 0.0, max: 5.0);

  static const Constraint_Ailment_Duration_Ice_Arrow = Constraint(min: 0.0, max: 5.0);
  static const Constraint_Ailment_Duration_Ice_Ball = Constraint(min: 0.0, max: 5.0);
  static const Constraint_Ailment_Duration_Fire_Arrow = Constraint(min: 0.0, max: 5.0);
  static const Constraint_Ailment_Duration_Fire_Ball = Constraint(min: 0.0, max: 5.0);

  static const Constraint_Range_Wind_Cut = Constraint(min: 50.0, max: 200.0);
  static const Constraint_Resist_Damage_Type = Constraint(min: 0.0, max: 0.5);

  static const Constraint_Resist = Constraint(min: 0, max: 0.5);

  const SkillType({
    required this.casteType,
    this.constraint,
    this.magicCost = 0,
    this.range,
    this.maxLevel = 20,
    this.isBaseAttack = false,
    this.enabledBow = false,
    this.enabledStaff = false,
    this.enabledSword = false,
    this.enabledUnarmed = false,
    this.damageMin,
    this.damageMax,
    this.isCaste = false,
  });

  bool get isPassive => casteType == CasteType.Passive;

  static SkillType parse(String name) =>
      tryParse(name) ?? (throw Exception('parse("$name")'));

  static SkillType? tryParse(String name){
     for (final skillType in values) {
        if (name == name)
          return skillType;
     }
     return null;
  }

  static int getHealAmount(int level) => 5 * level;

  // static double getAttackSpeedPercentage(int level){
  //   final value = interpolate(
  //     AmuletSettings.Min_Perform_Velocity,
  //     AmuletSettings.Max_Perform_Velocity,
  //     level / Max_Level,
  //   );
  //
  //   return getPercentageDiff(AmuletSettings.Min_Perform_Velocity, value);
  // }

  static double getHealthSteal(int level) =>
      Health_Steal.linearConstraint(SkillType.Constraint_Health_Steal, level);

  static double getMagicSteal(int level) =>
      Magic_Steal.linearConstraint(SkillType.Constraint_Health_Steal, level);

  static double getDamageIceArrow(int level) =>
      Ice_Arrow.linearConstraint(SkillType.Constraint_Damage_Ice_Arrow, level);

  static double getDamageIceBall(int level)  =>
      Ice_Ball.linearConstraint(SkillType.Constraint_Damage_Ice_Ball, level);

  static double getDamageFireArrow(int level) =>
      Fire_Arrow.linearConstraint(SkillType.Constraint_Damage_Fire_Arrow, level);

  static double getDamageFireBall(int level) =>
      Fire_Ball.linearConstraint(SkillType.Constraint_Damage_Fire_Ball, level);

  static double getDamageExplode(int level)  =>
      Explode.linearConstraint(SkillType.Constraint_Damage_Explode, level);

  static double getAilmentDurationIceArrow(int level) =>
      Ice_Arrow.linearConstraint(
          Constraint_Ailment_Duration_Ice_Arrow,
          level,
      );

  static double getAilmentDamageIceArrow(int level) =>
      Ice_Arrow.linearConstraint(
        Constraint_Ailment_Damage_Ice_Arrow,
        level,
      );

  static double getAilmentDurationFireball(int level) =>
      Fire_Ball.linearConstraint(
        Constraint_Ailment_Duration_Ice_Arrow,
        level,
      );

  static double getAilmentDurationFireArrow(int level) =>
      Fire_Arrow.linearConstraint(
        Constraint_Ailment_Duration_Fire_Arrow,
        level,
      );

  static double getAilmentDurationIceBall(int level) =>
      Ice_Ball.linearConstraint(
        Constraint_Ailment_Duration_Ice_Ball,
        level,
      );

  static double getAilmentDamageFireArrow(int level) =>
      Fire_Arrow.linearConstraint(
        Constraint_Ailment_Damage_Fire_Arrow,
        level,
      );

  static double getAilmentDamageFireball(int level) =>
      Fire_Ball.linearConstraint(
        Constraint_Ailment_Damage_Fire_Ball,
        level,
      );

  static double getAilmentDamageIceBall(int level) =>
      Ice_Ball.linearConstraint(
        Constraint_Ailment_Damage_Fire_Ball,
        level,
      );

  static double getPercentageMightySwing(int level) =>
      Critical_Hit.linearConstraint(Constraint_Might_Swing, level);

  static double getPercentageCriticalHit(int level) =>
      Critical_Hit.linearConstraint(Constraint_Critical_Hit, level);

  static int getSplitShotTotalArrows(int level) =>
      2 + level;

  static double getAreaDamage(int level) =>
      level / Area_Damage.maxLevel;

  static double getRunSpeed(int level) =>
      Run_Speed.linearConstraint(Constraint_Run_Speed, level);

  static List<SkillType> findByCasteType(CasteType casteType) =>
      values.where((element) => element.casteType == CasteType.Passive).toList(growable: false);

  static int getMaxHealth(int level){
    return level * 5;
  }

  static int getMaxMagic(int level){
    return level * 5;
  }

  /// returns between 0.0 and 1.0
  static double getAttackRange(int level) => Attack_Range.linear(level);

  double? getDamageMin(int? level) => tryLinearConstraint(damageMin, level);
  
  double? getDamageMax(int? level) => tryLinearConstraint(damageMax, level);
  
  double getLinear(int level) => tryLinearConstraint(constraint, level) ?? 0;

  double? tryLinearConstraint(Constraint? constraint, int? level) {
     if (constraint == null) {
       return null;
     }
     if (level == null){
       return null;
     }
     return linearConstraint(constraint, level);
  }

  double linearConstraint(Constraint constraint, int level) =>
      interpolate(
        constraint.min,
        constraint.max,
        level / maxLevel,
    );

  double linear(int level){
    if (maxLevel <= 0) {
      throw Exception();
    }
    return (level / maxLevel).clamp(0, 1);
  }

  static double getResistSlash(int level) => Resist_Slash.getLinear(level);

  static double getResistBludgeon(int level) => Resist_Bludgeon.getLinear(level);

  static double getResistPierce(int level) => Resist_Pierce.getLinear(level);

  static double getResistFire(int level) => Resist_Fire.getLinear(level);

  static double getResistIce(int level) => Resist_Ice.getLinear(level);

  static double getAttackSpeed(int level){
    final i = level / SkillType.Attack_Speed.maxLevel;
    return const Constraint(min: 1.0, max: 2.2).linearInterp(i);
  }

  static double getRangeWindCut(int level){
    final i = level / SkillType.Wind_Cut.maxLevel;
    return const Constraint(min: 1.0, max: 10.0).linearInterp(i);
  }

  static double getDamageWindCut(int level){
    final i = level / SkillType.Wind_Cut.maxLevel;
    return const Constraint(min: 80.0, max: 200.0).linearInterp(i);
  }
}

