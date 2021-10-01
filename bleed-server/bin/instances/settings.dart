
import '../classes/Settings.dart';
import '../common/Weapons.dart';

Settings settings = Settings();

Radius get radius => settings.radius;

Accuracy get accuracy => settings.accuracy;

CoolDown get coolDown => settings.coolDown;

double getWeaponAccuracy(Weapon weapon){
  switch (weapon){
    case Weapon.HandGun:
      return accuracy.handgun;
    case Weapon.Shotgun:
      return accuracy.shotgun;
    case Weapon.SniperRifle:
      return accuracy.sniperRifle;
    case Weapon.AssaultRifle:
      return accuracy.assaultRifle;
    default:
      throw Exception("No accuracy found for $weapon");
  }
}