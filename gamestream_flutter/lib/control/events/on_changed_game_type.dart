

import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:lemon_engine/engine.dart';

void onChangedGameType(int? value){
  print("onChangedGameType(${GameType.getName(value)})");
  if (value == null) {
    return;
  }
  game.edit.value = value == GameType.Editor;
  game.timeVisible.value = GameType.isTimed(value);
  game.mapVisible.value = value == GameType.Dark_Age;
  Engine.fullScreenEnter();
}