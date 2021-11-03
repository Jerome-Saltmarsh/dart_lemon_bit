import 'package:bleed_client/common/Weapons.dart';
import 'package:flutter/painting.dart';

final _DecorationImages _decorationImages = _DecorationImages();

DecorationImage mapWeaponToImage(Weapon weapon) {
  switch (weapon) {
    case Weapon.HandGun:
      return _decorationImages.handgun;
    case Weapon.Shotgun:
      return _decorationImages.shotgun;
    case Weapon.SniperRifle:
      return _decorationImages.sniper;
    case Weapon.AssaultRifle:
      return _decorationImages.assaultRifle;
  }
  throw Exception("no image available for $weapon");
}

class _DecorationImages {
  final DecorationImage handgun = const DecorationImage(
    image: const AssetImage('images/weapon-handgun.png'),
  );

  final DecorationImage shotgun = const DecorationImage(
    image: const AssetImage('images/weapon-shotgun.png'),
  );

  final DecorationImage sniper = const DecorationImage(
    image: const AssetImage('images/weapon-sniper-rifle.png'),
  );

  final DecorationImage assaultRifle = const DecorationImage(
    image: const AssetImage('images/weapon-machine-gun.png'),
  );
}
