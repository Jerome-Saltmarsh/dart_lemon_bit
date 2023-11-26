
import 'package:bleed_common/Shade.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/watches/ambient_shade.dart';

import '../events/on_action_finished_lightning_flash.dart';
import '../game_action.dart';

void actionLightningFlash() {
  audioSingleThunder(1.0);
  if (ambientShade.value == Shade.Very_Bright) return;
  ambientShade.value = Shade.Very_Bright;
  runAction(duration: 8, action: onActionFinishedLightningFlash);
}
