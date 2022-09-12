
import 'package:bleed_common/attack_type.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';

void onGameEventWeaponTypeEquipped(int attackType, double x, double y, double z) {
  switch (attackType) {
    case AttackType.Shotgun:
      audioSingleShotgunCock.playXYZ(x, y, z);
      break;
    case AttackType.Handgun:
      audioSingleGunPickup.playXYZ(x, y, z);
      break;
    default:
      break;
  }
}