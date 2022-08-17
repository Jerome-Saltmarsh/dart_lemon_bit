import 'package:bleed_common/library.dart';

import '../audio/audio_singles.dart';

void onChangedPlayerWeapon(int value) {
  if (WeaponType.isMetal(value)) {
    audioSingleDrawSword.play();
  } else {
    // audioSingleChanging.play();
  }
}
