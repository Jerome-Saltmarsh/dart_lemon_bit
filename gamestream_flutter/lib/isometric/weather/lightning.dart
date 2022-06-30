import 'package:bleed_common/Shade.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:lemon_math/library.dart';
import 'package:gamestream_flutter/isometric/game_action.dart';
import 'package:lemon_watch/watch.dart';

import '../audio/audio_singles.dart';

final weatherLightning = Watch(false, onChanged: (bool lightningOn){
   if (lightningOn){
     nextLightning = 0;
   }
});
var nextLightning = 0;

void weatherLightningToggle() => weatherLightning.value = !weatherLightning.value;

bool get lightningOn => weatherLightning.value;

void weatherUpdateLightning(){
    if (!lightningOn) return;
    if (nextLightning-- > 0) return;
    actionLightningFlash();
    nextLightning = randomInt(200, 1500);
}

void actionLightningFlash() {
  audioSingleThunder(1.0);
  if (ambient.value == Shade.Very_Bright) return;
  ambient.value = Shade.Very_Bright;
  runAction(duration: 8, action: refreshAmbient);
}
