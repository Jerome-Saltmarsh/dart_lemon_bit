
import 'Weapons.dart';

_Constants constants = _Constants();

_Prices get prices => constants.prices;

class _Constants {
  int pointsEarnedZombieKilled = 5;
  _Prices prices = _Prices();
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

int mapWeaponPrice(Weapon weapon){
  switch(weapon){
    case Weapon.HandGun:
      return prices.weapon.handgun;
    case Weapon.Shotgun:
      return prices.weapon.shotgun;
    case Weapon.SniperRifle:
      return prices.weapon.sniperRifle;
    case Weapon.AssaultRifle:
      return prices.weapon.assaultRifle;
  }
  throw Exception("No price available for $weapon");
}

String mapWeaponName(Weapon weapon){
  switch(weapon){
    case Weapon.HandGun:
      return "Handgun";
    case Weapon.Shotgun:
      return "Shotgun";
    case Weapon.SniperRifle:
      return "Sniper Rifle";
    case Weapon.AssaultRifle:
      return "Assault Rifle";
  }
  throw Exception("No name available for $weapon");
}