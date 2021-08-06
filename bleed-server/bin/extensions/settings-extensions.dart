

import '../enums/Weapons.dart';
import '../instances/settings.dart';

double getWeaponAccuracy(Weapon weapon){
  switch (weapon){
    case Weapon.HandGun:
      return settings.handgunAccuracy;
    case Weapon.Shotgun:
      return settings.shotgunAccuracy;
    case Weapon.SniperRifle:
      return settings.sniperRifleAccuracy;
    case Weapon.MachineGun:
      return settings.machineGunAccuracy;
    default:
      throw Exception("no range found for $weapon");
  }
}