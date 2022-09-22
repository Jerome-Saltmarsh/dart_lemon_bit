

import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/modules/modules.dart';

void onChangedGameType(int? value){
  print("onChangedGameType($value)");
  modules.game.state.timeVisible.value = value != GameType.Waves;
}