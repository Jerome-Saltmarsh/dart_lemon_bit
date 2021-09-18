_Prices prices = _Prices();

class _Prices {
  final _Weapon weapon = _Weapon();
  final _Ammo ammo = _Ammo();
}

class _Weapon {
  final int handgun = 20;
  final int shotgun = 20;
  final int sniperRifle = 30;
  final int assaultRifle = 30;
}

class _Ammo {
  final int handgun = 20;
  final int shotgun = 20;
  final int sniperRifle = 100;
  final int assaultRifle = 200;
}