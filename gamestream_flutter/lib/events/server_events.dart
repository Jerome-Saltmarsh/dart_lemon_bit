
import 'package:gamestream_flutter/library.dart';

class ServerEvents {
  static void onChangedGameType(int? value){
    print("gamestream.onChangedGameType(${GameType.getName(value)})");
    if (value == null) {
      return;
    }
    ClientState.edit.value = value == GameType.Editor;
    GameUI.timeVisible.value = GameType.isTimed(value);
    GameUI.mapVisible.value = value == GameType.Dark_Age;

    if (!Engine.isLocalHost){
      Engine.fullScreenEnter();
    }
  }

  static void onChangedLightning(Lightning lightning){
    if (lightning != Lightning.Off){
      ClientState.nextLightning = 0;
    }
  }

}