import '../../../common.dart';

enum MMOAttackType {
  Melee(PowerMode.Targeted_Enemy),
  Arrow(PowerMode.Targeted_Enemy),
  Fire_Arrow(PowerMode.Targeted_Enemy),
  Ice_Arrow(PowerMode.Targeted_Enemy),
  Electric_Arrow(PowerMode.Targeted_Enemy),
  Bullet(PowerMode.Targeted_Enemy),
  Rocket(PowerMode.Targeted_Enemy),
  Frost_Ball(PowerMode.Targeted_Enemy),
  Electricity_Ball(PowerMode.Targeted_Enemy),
  Fire_Ball(PowerMode.Targeted_Enemy),
  Freeze_Circle(PowerMode.Positional),
  Blink(PowerMode.Positional),
  Heal(PowerMode.Targeted_Ally);

  const MMOAttackType(this.mode);

  final PowerMode mode;
}