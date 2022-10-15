
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/audio_engine.dart';

import 'website/website.dart';

class GameEvents {

  static void onError(Object error, StackTrace stack){
    print(error.toString());
    print(stack);
    Website.error.value = error.toString();
  }

  static void onGameEventWeaponTypeEquipped(int attackType, double x, double y, double z) {
    switch (attackType) {
      case AttackType.Shotgun:
        AudioEngine.audioSingleShotgunCock.playXYZ(x, y, z);
        break;
      default:
        break;
    }
  }
}