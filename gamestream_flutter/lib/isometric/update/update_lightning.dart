
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/watches/lightning.dart';
import 'package:lemon_math/library.dart';

import '../variables/next_lightning.dart';

void updateLightning(){
  if (lightning.value != Lightning.On) return;
  if (nextLightning-- > 0) return;
  GameState.actionLightningFlash();
  nextLightning = randomInt(200, 1500);
}
