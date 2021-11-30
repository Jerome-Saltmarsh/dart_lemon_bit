import 'package:bleed_client/common/WeaponType.dart';
import 'package:flutter/painting.dart';

final Map<WeaponType, DecorationImage> mapWeaponTypeToImage = {
  WeaponType.HandGun: _load("weapon-handgun"),
  WeaponType.Shotgun: _load("weapon-shotgun"),
  WeaponType.Unarmed: _load("weapon-unarmed"),
  WeaponType.SniperRifle: _load("weapon-sniper-rifle"),
  WeaponType.Firebolt: _load("weapon-fireball"),
  WeaponType.AssaultRifle: _load("weapon-machine-gun"),
};

DecorationImage _load(String filename) {
  return DecorationImage(
    image: AssetImage('images/$filename.png'),
  );
}
