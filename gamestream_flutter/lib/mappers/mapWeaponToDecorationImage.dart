import 'package:flutter/painting.dart';
import 'package:bleed_common/WeaponType.dart';

final Map<WeaponType, DecorationImage> mapWeaponTypeToImage = {
  WeaponType.HandGun: _load("weapon-handgun"),
  WeaponType.Shotgun: _load("weapon-shotgun"),
  WeaponType.Unarmed: _load("weapon-unarmed"),
  WeaponType.SniperRifle: _load("weapon-sniper-rifle"),
  WeaponType.AssaultRifle: _load("weapon-machine-gun"),
};

DecorationImage _load(String filename) {
  return DecorationImage(
    image: AssetImage('images/$filename.png'),
  );
}
