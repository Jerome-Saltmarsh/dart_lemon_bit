import 'package:lemon_math/src.dart';

import 'amulet_item.dart';
import 'amulet_settings.dart';

enum SkillType {
  None(
      casteType: CasteType.Caste,
      range: 0,
      casteSpeed: AttackSpeed.Very_Slow,
  ),
  Strike(
      casteType: CasteType.Melee,
      magicCost: 0,
  ),
  Mighty_Strike(
      casteType: CasteType.Sword,
      magicCost: 3,
  ),
  Frostball(
      casteType: CasteType.Staff,
      magicCost: 4,
      range: 125,
  ),
  Fireball(
      casteType: CasteType.Staff,
      magicCost: 5,
      range: 150,
  ),
  Explode(
      casteType: CasteType.Staff,
      magicCost: 7,
      range: 125,
  ),
  // BOW
  Shoot_Arrow(
      casteType: CasteType.Bow,
      magicCost: 0,
  ),
  Split_Shot(
      casteType: CasteType.Bow,
      magicCost: 4,
  ),
  Ice_Arrow(
      casteType: CasteType.Bow,
      magicCost: 4,
  ),
  Fire_Arrow(
      casteType: CasteType.Bow,
      magicCost: 4,
  ),
  // CASTE
  Heal(
      casteType: CasteType.Staff,
      magicCost: 4,
      casteSpeed: AttackSpeed.Fast,
      range: 0,
  ),
  Agility(
    casteType: CasteType.Passive,
  ),
  Vampire(
    casteType: CasteType.Passive,
  ),
  Warlock(
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
  ),
  Shield(
    casteType: CasteType.Passive,
  ),
  Wind_Cut(
    casteType: CasteType.Sword,
  ),
  ;


  final CasteType casteType;
  final int magicCost;
  /// if null the weapon perform duration is used
  final AttackSpeed? casteSpeed;
  /// if null the weapon range is used
  final double? range;

  static const Max_Skill_Points = 20;
  static const Max_Health_Steal = 0.5;
  static const Max_Magic_Steal = 0.5;
  static const Max_Critical_Hit = 0.5;
  static const Max_Might_Swing = 3.0;
  static const Max_Resist = 0.5;
  static const Max_Run_Speed = 0.4;
  static const Min_Wind_Cut_Range = 50.0;
  static const Max_Wind_Cut_Range = 200.0;

  const SkillType({
    required this.casteType,
    this.magicCost = 0,
    this.casteSpeed,
    this.range,
  });

  bool get isPassive => casteType == CasteType.Passive;

  static void validate() {
    for (final skillType in values){
      if (skillType.casteType == CasteType.Caste){
        if (skillType.range == null){
          throw Exception('$skillType.range cannot be null');
        }
        if (skillType.casteSpeed == null){
          throw Exception('$skillType.casteDuration cannot be null');
        }
      }
    }
  }

  static SkillType parse(String name) =>
      tryParse(name) ?? (throw Exception('SkillType.parse("$name")'));

  static SkillType? tryParse(String name){
     for (final skillType in values) {
        if (skillType.name == name)
          return skillType;
     }
     return null;
  }

  static int getHealAmount(int level) => 5 * level;

  static double getAttackSpeedPercentage(int level){
    final value = interpolate(
      AmuletSettings.Min_Perform_Velocity,
      AmuletSettings.Max_Perform_Velocity,
      level / SkillType.Max_Skill_Points,
    );

    return getPercentageDiff(AmuletSettings.Min_Perform_Velocity, value);
  }

  static double getHealthSteal(int level) =>
      interpolate(0, SkillType.Max_Health_Steal, level / Max_Skill_Points);

  static double getMagicSteal(int level) =>
      interpolate(0, SkillType.Max_Magic_Steal, level / Max_Skill_Points);

  static double getDamageExplode(int level){
    return level * 4.0;
  }

  static double getDamageFireball(int level){
    return level * 2.0;
  }

  static double getDamageIceArrow(int level){
     return level * 2.0;
  }

  static double getDamageFireArrow(int level){
    return level * 2.0;
  }

  static double getDamageFrostBall(int level){
    return level * 2.0;
  }

  static int getAilmentDurationIceArrow(int level){
    throw Exception();
  }

  static double getAilmentDamageIceArrow(int level){
    throw Exception();
  }

  static int getAilmentDurationFireball(int level){
    throw Exception();
  }

  static int getAilmentDurationFireArrow(int level){
    throw Exception();
  }

  static int getAilmentDurationFrostBall(int level){
    throw Exception();
  }

  static double getAilmentDamageFireArrow(int level){
    throw Exception();
  }

  static double getAilmentDamageFireball(int level){
    throw Exception();
  }

  static double getAilmentDamageFrostBall(int level){
    throw Exception();
  }

  static double getPercentageMightySwing(int level){
    final i = level / Max_Skill_Points;
    return interpolate(0, Max_Might_Swing, i);
  }

  static double getRangeWindCut(int level){
    final i = level / Max_Skill_Points;
    return interpolate(Min_Wind_Cut_Range, Max_Wind_Cut_Range, i);
  }

  static double getPercentageCriticalHit(int level){
    final i = level / Max_Skill_Points;
    return interpolate(0, Max_Critical_Hit, i);
  }

  static double getPercentageDamageResistanceMelee(int level){
    final i = level / Max_Skill_Points;
    return interpolate(0, Max_Resist, i);
  }

  static int getSplitShotTotalArrows(int level){
    return 2 + level;
  }

  static double getAreaDamage(int level){
    return level / Max_Skill_Points;
  }

  static double getRunSpeed(int level){
    final i = level / SkillType.Max_Skill_Points;
    return interpolate(0, SkillType.Max_Run_Speed, i);
  }

  static final collectionPassive = findByCasteType(CasteType.Passive);
  static final collectionSword = findByCasteType(CasteType.Sword);
  static final collectionStaff = findByCasteType(CasteType.Staff);

  static const valuesBow = [
    SkillType.Ice_Arrow,
    SkillType.Fire_Arrow,
    SkillType.Split_Shot,
  ];

  static List<SkillType> findByCasteType(CasteType casteType) =>
      values.where((element) => element.casteType == CasteType.Passive).toList(growable: false);
}

