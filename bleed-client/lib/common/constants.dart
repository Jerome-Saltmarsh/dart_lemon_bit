
import 'Weapons.dart';

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
    case Weapon.Unarmed:
      return 0;
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
    case Weapon.Unarmed:
      return "Unarmed";
  }
}

class _MaxRounds {
  final int handgun = 100;
  final int shotgun = 30;
  final int sniperRifle = 15;
  final int assaultRifle = 250;
}

int getMaxRounds(Weapon weapon){
  switch(weapon){
    case Weapon.Unarmed:
      return 0;
    case Weapon.HandGun:
      return constants.maxRounds.handgun;
    case Weapon.Shotgun:
      return constants.maxRounds.shotgun;
    case Weapon.SniperRifle:
      return constants.maxRounds.sniperRifle;
    case Weapon.AssaultRifle:
      return constants.maxRounds.assaultRifle;
  }
}