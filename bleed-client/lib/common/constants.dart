
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
  final int sniperRifle = 100;
  final int assaultRifle = 200;
}

class _Ammo {
  final int handgun = 50;
  final int shotgun = 75;
  final int sniperRifle = 100;
  final int assaultRifle = 200;
}