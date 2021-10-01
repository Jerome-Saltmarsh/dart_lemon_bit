
import '../classes/Settings.dart';
import '../common/Weapons.dart';

Settings settings = Settings();

Radius get radius => settings.radius;

Accuracy get _accuracy => settings.accuracy;

CoolDown get coolDown => settings.coolDown;

Damage get _damage => settings.damage;

Range get _range => settings.range;

double getWeaponAccuracy(Weapon weapon){
  switch (weapon){
    case Weapon.HandGun:
      return _accuracy.handgun;
    case Weapon.Shotgun:
      return _accuracy.shotgun;
    case Weapon.SniperRifle:
      return _accuracy.sniperRifle;
    case Weapon.AssaultRifle:
      return _accuracy.assaultRifle;
    default:
      throw Exception("No accuracy found for $weapon");
  }
}

int getWeaponDamage(Weapon weapon){
  switch (weapon){
    case Weapon.HandGun:
      return _damage.handgun;
    case Weapon.Shotgun:
      return _damage.shotgun;
    case Weapon.SniperRifle:
      return _damage.sniperRifle;
    case Weapon.AssaultRifle:
      return _damage.assaultRifle;
    default:
      throw Exception("No accuracy found for $weapon");
  }
}

double getWeaponRange(Weapon weapon) {
  switch (weapon) {
    case Weapon.HandGun:
      return _range.handgun;
    case Weapon.Shotgun:
      return _range.shotgun;
    case Weapon.SniperRifle:
      return _range.sniperRifle;
    case Weapon.AssaultRifle:
      return _range.assaultRifle;
    default:
      throw Exception("no range found for $weapon");
  }
}