import 'package:bleed_common/lightning.dart';
import 'package:bleed_common/Shade.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:lemon_math/library.dart';
import 'package:gamestream_flutter/isometric/game_action.dart';
import 'package:lemon_watch/watch.dart';

import '../audio/audio_singles.dart';
import 'ambient_shade.dart';

final lightning = Watch(Lightning.Off, onChanged: (Lightning value){
   if (value != Lightning.Off){
     nextLightning = 0;
   }
});
var nextLightning = 0;

bool get lightningOn => lightning.value != Lightning.Off;

void weatherUpdateLightning(){
    if (lightning.value != Lightning.On) return;
    if (nextLightning-- > 0) return;
    actionLightningFlash();
    nextLightning = randomInt(200, 1500);
}

void actionLightningFlash() {
  audioSingleThunder(1.0);
  if (ambientShade.value == Shade.Very_Bright) return;
  ambientShade.value = Shade.Very_Bright;
  runAction(duration: 8, action: actionSetAmbientShadeToHour);
}
