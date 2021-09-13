
import '../classes/Settings.dart';
import '../common/Weapons.dart';

Settings settings = Settings();

double getWeaponAccuracy(Weapon weapon){
  switch (weapon){
    case Weapon.HandGun:
      return settings.handgunAccuracy;
    case Weapon.Shotgun:
      return settings.shotgunAccuracy;
    case Weapon.SniperRifle:
      return settings.sniperRifleAccuracy;
    case Weapon.AssaultRifle:
      return settings.machineGunAccuracy;
    default:
      throw Exception("no range found for $weapon");
  }
}