

import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/modules/modules.dart';

void onChangedGameType(int? value){
  print("onChangedGameType(${GameType.getName(value)})");
  if (value == null) return;
  modules.game.state.timeVisible.value = GameType.isTimed(value);
}