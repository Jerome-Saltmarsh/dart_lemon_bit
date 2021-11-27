
import 'WeaponType.dart';

_Constants constants = _Constants();

_Prices get prices => constants.prices;

class _Constants {
  _Prices prices = _Prices();
  _Points points = _Points();
  _MaxRounds maxRounds = _MaxRounds();
}

class _Points {
  final int zombieKilled = 5;
}

class _Prices {
  final _Weapon weapon = _Weapon();
  final _Ammo ammo = _Ammo();
}

class _Weapon {
  final int handgun = 50;
  final int shotgun = 15;
  final int sniperRifle = 10;
  final int assaultRifle = 10;
}

class _Ammo {
  final int handgun = 50;
  final int shotgun = 75;
  final int sniperRifle = 100;
  final int assaultRifle = 200;
}

int mapWeaponPrice(WeaponType weapon){
  switch(weapon){
    case WeaponType.HandGun:
      return prices.weapon.handgun;
    case WeaponType.Shotgun:
      return prices.weapon.shotgun;
    case WeaponType.SniperRifle:
      return prices.weapon.sniperRifle;
    case WeaponType.AssaultRifle:
      return prices.weapon.assaultRifle;
    case WeaponType.Unarmed:
      return 0;
  }
  throw Exception("No price available for $weapon");
}

String mapWeaponName(WeaponType weapon){
  switch(weapon){
    case WeaponType.HandGun:
      return "Handgun";
    case WeaponType.Shotgun:
      return "Shotgun";
    case WeaponType.SniperRifle:
      return "Sniper Rifle";
    case WeaponType.AssaultRifle:
      return "Assault Rifle";
    case WeaponType.Unarmed:
      return "Unarmed";
  }
}

class _MaxRounds {
  final int handgun = 100;
  final int shotgun = 30;
  final int sniperRifle = 15;
  final int assaultRifle = 250;
}

int getMaxRounds(WeaponType weapon){
  switch(weapon){
    case WeaponType.Unarmed:
      return 0;
    case WeaponType.HandGun:
      return constants.maxRounds.handgun;
    case WeaponType.Shotgun:
      return constants.maxRounds.shotgun;
    case WeaponType.SniperRifle:
      return constants.maxRounds.sniperRifle;
    case WeaponType.AssaultRifle:
      return constants.maxRounds.assaultRifle;
  }
}