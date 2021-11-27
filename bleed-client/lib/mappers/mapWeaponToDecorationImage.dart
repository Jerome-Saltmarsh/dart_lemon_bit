import 'package:bleed_client/common/WeaponType.dart';
import 'package:flutter/painting.dart';

final _DecorationImages _decorationImages = _DecorationImages();

DecorationImage mapWeaponToImage(WeaponType weapon) {
  switch (weapon) {
    case WeaponType.Unarmed:
      return _decorationImages.unarmed;
    case WeaponType.HandGun:
      return _decorationImages.handgun;
    case WeaponType.Shotgun:
      return _decorationImages.shotgun;
    case WeaponType.SniperRifle:
      return _decorationImages.sniper;
    case WeaponType.AssaultRifle:
      return _decorationImages.assaultRifle;
  }
  throw Exception("no image available for $weapon");
}

class _DecorationImages {
  final DecorationImage handgun = const DecorationImage(
    image: const AssetImage('images/weapon-handgun.png'),
  );

  final DecorationImage unarmed = const DecorationImage(
    image: const AssetImage('images/weapon-unarmed.png'),
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
