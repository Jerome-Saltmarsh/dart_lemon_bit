import 'amulet_power_mode.dart';

enum AmuletAttackType {
  Caste(AmuletPowerMode.Equip),
  Melee(AmuletPowerMode.Equip),
  Arrow(AmuletPowerMode.Equip),
  Fire_Arrow(AmuletPowerMode.Equip),
  Ice_Arrow(AmuletPowerMode.Equip),
  Electric_Arrow(AmuletPowerMode.Equip),
  Bullet(AmuletPowerMode.Equip),
  Rocket(AmuletPowerMode.Equip),
  Frost_Ball(AmuletPowerMode.Equip),
  Electricity_Ball(AmuletPowerMode.Equip),
  Fire_Ball(AmuletPowerMode.Equip),
  Freeze_Circle(AmuletPowerMode.Positional),
  Blink(AmuletPowerMode.Positional),
  Lightning(AmuletPowerMode.Self),
  Heal(AmuletPowerMode.Targeted_Ally);

  const AmuletAttackType(this.mode);

  final AmuletPowerMode mode;
}