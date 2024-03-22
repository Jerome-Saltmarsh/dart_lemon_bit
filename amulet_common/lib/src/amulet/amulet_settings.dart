import 'package:lemon_math/src.dart';

class AmuletSettings {
  static const Amount_Skill_Type_Split_Shot_Base = 3;
  static const Ratio_Critical_Hit_Damage = 2.0;
  static const Ratio_Skill_Type_Split_Shot_Amount = 0.25;
  static const Ratio_Frame_Velocity_Agility = 0.05;
  static const Chance_Blind_Miss = 0.3;

  /// in seconds
  static const Duration_Condition_Blind = 4;
  static const Player_Revive_Timer = 3;
  static const Min_Perform_Velocity = 1.0;
  static const Max_Perform_Velocity = 2.0;
  static const Base_Magic_Regen = 1;
  static const Base_Health_Regen = 1;
  static const Base_Agility = 1.0;

  static const Chance_Of_Drop_Item_On_Grass_Cut = 0.2;
  static const Chance_Of_Drop_Loot = 0.25;
  static const Chance_Of_Drop_Loot_Rare = 0.05;
  static const Chance_Of_Drop_Loot_Unique = 0.1;
  static const Chance_Of_Drop_Loot_Common = 0.15;
  static const Chance_Of_Drop_Loot_Consumable = 0.15;

  static const Attack_Speed_Duration_Slowest = 80;
  static const Attack_Speed_Duration_Fastest = 24;

  static double interpolateAttackSpeed(double t) =>
      interpolate(Attack_Speed_Duration_Fastest, Attack_Speed_Duration_Slowest, 1.0 - t);
}
