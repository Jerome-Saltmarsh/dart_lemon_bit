
import 'package:gamestream_flutter/library.dart';

class ServerEvents {

  static void onChangedAreaType(int areaType) {
    print("ServerEvents.onChangedAreaType(${AreaType.getName(areaType)})");
     ClientState.areaTypeVisible.value = true;
  }

  static void onChangedGameType(int? value){
    print("gamestream.onChangedGameType(${GameType.getName(value)})");
    if (value == null) {
      return;
    }
    ClientState.edit.value = value == GameType.Editor;
    GameUI.timeVisible.value = value == GameType.Dark_Age;
    GameUI.mapVisible.value = value == GameType.Dark_Age;

    if (!Engine.isLocalHost){
      Engine.fullScreenEnter();
    }
  }

  static void onChangedLightningFlashing(bool lightningFlashing){
    if (lightningFlashing) {
      // GameLighting.setStartHSVColor(GameLighting.Color_Lightning);
      // GameLighting.refreshValues();
      GameAudio.thunder(1.0);
    } else {
      // GameLighting.setStartHSVColor(GameLighting.Ambient_Color_HSV.withAlpha(0));
      ClientState.updateGameLighting();
    }
  }

  static void onChangedGameTimeEnabled(bool value){
    GameUI.timeVisible.value = value;
  }
}