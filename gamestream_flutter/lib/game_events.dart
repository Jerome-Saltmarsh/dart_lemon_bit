
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/audio_engine.dart';

class GameEvents {
  static void onWeaponTypeEquipped(int attackType, double x, double y, double z) {
    switch (attackType) {
      case AttackType.Shotgun:
        AudioEngine.audioSingleShotgunCock.playXYZ(x, y, z);
        break;
      default:
        break;
    }
  }
}