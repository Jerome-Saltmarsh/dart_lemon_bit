
import 'package:lemon_math/src.dart';

import 'amulet_settings.dart';
import 'caste_type.dart';

enum SkillType {
  None(
      casteType: CasteType.Self,
      range: 0,
  ),
  Slash(
      casteType: CasteType.Sword,
      magicCost: 0,
  ),
  Bludgeon(
      casteType: CasteType.Staff,
      magicCost: 0,
  ),
  Mighty_Strike(
      casteType: CasteType.Sword,
      magicCost: 3,
  ),
  Frostball(
      casteType: CasteType.Staff,
      magicCost: 4,
  ),
  Fireball(
      casteType: CasteType.Staff,
      magicCost: 5,
  ),
  Explode(
      casteType: CasteType.Staff,
      magicCost: 7,
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
      range: 0,
  ),
  Max_Health(
    casteType: CasteType.Passive,
  ),
  Max_Magic(
    casteType: CasteType.Passive,
  ),
  Attack_Speed(
    casteType: CasteType.Passive,
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
  Scout(
    casteType: CasteType.Passive,
  ),
  Shield(
    casteType: CasteType.Passive,
  ),
  Wind_Cut(
    casteType: CasteType.Sword,
  ),
  ;


  final int maxLevel;
  final CasteType casteType;
  final int magicCost;
  /// if null the weapon perform duration is used
  /// if null the weapon range is used
  final double? range;

  static const Max_Level = 20;
  static const Max_Health_Steal = 0.5;
  static const Max_Magic_Steal = 0.5;
  static const Max_Critical_Hit = 0.5;
  static const Max_Might_Swing = 3.0;
  static const Max_Resist = 0.5;
  static const Max_Run_Speed = 0.4;

  static const Range_Min_Wind_Cut = 50.0;
  static const Range_Max_Wind_Cut = 200.0;

  static const Damage_Max_Fire_Arrow = 20.0;
  static const Damage_Min_Fire_Arrow = 2.0;

  static const Damage_Max_Ice_Arrow = 20.0;
  static const Damage_Min_Ice_Arrow = 2.0;

  static const Damage_Min_Fireball = 2.0;
  static const Damage_Max_Fireball = 20.0;

  static const Damage_Min_Explode = 2.0;
  static const Damage_Max_Explode = 20.0;

  static const Damage_Min_Frostball = 2.0;
  static const Damage_Max_Frostball = 20.0;

  static const Ailment_Damage_Min_Ice_Arrow = 1.0;
  static const Ailment_Damage_Min_Fire_Arrow = 1.0;

  static const Ailment_Damage_Max_Ice_Arrow = 5.0;
  static const Ailment_Damage_Max_Fire_Arrow = 5.0;

  static const Ailment_Damage_Min_Fireball = 1.0;
  static const Ailment_Damage_Max_Fireball = 5.0;

  static const Ailment_Damage_Min_Frostball = 0.0;
  static const Ailment_Damage_Max_Frostball = 1.0;

  static const Ailment_Duration_Min_Ice_Arrow = 1.0;
  static const Ailment_Duration_Max_Ice_Arrow = 5.0;

  static const Ailment_Duration_Min_Fireball = 1.0;
  static const Ailment_Duration_Max_Fireball = 5.0;

  static const Ailment_Duration_Min_Fire_Arrow = 1.0;
  static const Ailment_Duration_Max_Fire_Arrow = 5.0;

  static const Ailment_Duration_Min_Frostball = 1.0;
  static const Ailment_Duration_Max_Frostball = 5.0;

  const SkillType({
    required this.casteType,
    this.magicCost = 0,
    this.range,
    this.maxLevel = 20,
  });

  bool get isPassive => casteType == CasteType.Passive;

  static void validate() {
    for (final skillType in values){
      if (skillType.casteType == CasteType.Self){
        if (skillType.range == null){
          throw Exception('$skillType.range cannot be null');
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
      level / SkillType.Max_Level,
    );

    return getPercentageDiff(AmuletSettings.Min_Perform_Velocity, value);
  }

  static double getHealthSteal(int level) =>
      linear(0, SkillType.Max_Health_Steal, level);

  static double getMagicSteal(int level) =>
      linear(0, SkillType.Max_Magic_Steal, level);

  static double getDamageFireball(int level) =>
      linear(
        SkillType.Damage_Min_Fireball,
        SkillType.Damage_Max_Fireball,
        level,
      );

  static double getDamageIceArrow(int level) =>
      linear(
        SkillType.Damage_Min_Ice_Arrow,
        SkillType.Damage_Max_Ice_Arrow,
        level,
      );

  static double getDamageFireArrow(int level) =>
      linear(
        SkillType.Damage_Min_Fire_Arrow,
        SkillType.Damage_Max_Fire_Arrow,
        level,
      );

  static double getDamageExplode(int level) =>
      linear(
        SkillType.Damage_Min_Explode,
        SkillType.Damage_Max_Explode,
        level,
      );

  static double getDamageFrostBall(int level) =>
      linear(
        SkillType.Damage_Min_Frostball,
        SkillType.Damage_Max_Frostball,
        level,
      );

  static double getAilmentDurationIceArrow(int level) =>
      linear(
        SkillType.Ailment_Duration_Min_Ice_Arrow,
        SkillType.Ailment_Duration_Max_Ice_Arrow,
        level,
      );

  static double getAilmentDamageIceArrow(int level) =>
      linear(
        SkillType.Ailment_Damage_Min_Ice_Arrow,
        SkillType.Ailment_Damage_Max_Ice_Arrow,
        level,
      );

  static double getAilmentDurationFireball(int level) =>
      linear(
        SkillType.Ailment_Duration_Min_Fireball,
        SkillType.Ailment_Duration_Max_Fireball,
        level,
      );

  static double getAilmentDurationFireArrow(int level) =>
      linear(
        SkillType.Ailment_Duration_Min_Fire_Arrow,
        SkillType.Ailment_Duration_Max_Fire_Arrow,
        level,
      );

  static double getAilmentDurationFrostBall(int level) =>
      linear(
        SkillType.Ailment_Duration_Min_Frostball,
        SkillType.Ailment_Duration_Max_Frostball,
        level,
      );

  static double getAilmentDamageFireArrow(int level) =>
      linear(
        SkillType.Ailment_Damage_Min_Fire_Arrow,
        SkillType.Ailment_Damage_Max_Fire_Arrow,
        level,
      );

  static double getAilmentDamageFireball(int level) =>
      linear(
        SkillType.Ailment_Damage_Min_Fireball,
        SkillType.Ailment_Damage_Max_Fireball,
        level,
      );

  static double getAilmentDamageFrostBall(int level) =>
      linear(
        SkillType.Ailment_Damage_Min_Frostball,
        SkillType.Ailment_Damage_Max_Frostball,
        level,
      );

  static double getPercentageMightySwing(int level) =>
      linear(0, Max_Might_Swing, level);

  static double getRangeWindCut(int level) =>
      linear(0, 1, level);

  static double getPercentageCriticalHit(int level) =>
      linear(0, Max_Critical_Hit, level);

  static double getPercentageDamageResistanceMelee(int level) =>
      linear(0, Max_Resist, level);

  static int getSplitShotTotalArrows(int level) =>
      2 + level;

  static double getAreaDamage(int level) =>
      level / Max_Level;

  static double getRunSpeed(int level) =>
      linear(0, SkillType.Max_Run_Speed, level);

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


  static int getMaxHealth(int level){
    return level * 5;
  }

  static int getMaxMagic(int level){
    return level * 5;
  }

  static double linear(double start, double end, int level) =>
      interpolate(
        start,
        end,
        level / Max_Level,
    );

}

