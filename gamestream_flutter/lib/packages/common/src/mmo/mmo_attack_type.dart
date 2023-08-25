import 'power_mode.dart';

enum MMOAttackType {
  Melee(PowerMode.Equip),
  Arrow(PowerMode.Equip),
  Fire_Arrow(PowerMode.Equip),
  Ice_Arrow(PowerMode.Equip),
  Electric_Arrow(PowerMode.Equip),
  Bullet(PowerMode.Equip),
  Rocket(PowerMode.Equip),
  Frost_Ball(PowerMode.Equip),
  Electricity_Ball(PowerMode.Equip),
  Fire_Ball(PowerMode.Equip),
  Freeze_Circle(PowerMode.Positional),
  Blink(PowerMode.Positional),
  Heal(PowerMode.Targeted_Ally);

  const MMOAttackType(this.mode);

  final PowerMode mode;
}