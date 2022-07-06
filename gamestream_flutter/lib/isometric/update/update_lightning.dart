
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/state/next_lightning.dart';
import 'package:gamestream_flutter/isometric/watches/lightning.dart';

import 'package:lemon_math/library.dart';
import '../actions/action_lightning_flash.dart';

void updateLightning(){
  if (lightning.value != Lightning.On) return;
  if (nextLightning-- > 0) return;
  actionLightningFlash();
  nextLightning = randomInt(200, 1500);
}
