
import 'package:gamestream_flutter/library.dart';

class ServerEvents {

  static void onChangedAreaType(int areaType) {
     gamestream.games.isometric.clientState2.areaTypeVisible.value = true;
  }

  static void onChangedLightningFlashing(bool lightningFlashing){
    if (lightningFlashing) {
      gamestream.audio.thunder(1.0);
    } else {
      gamestream.games.isometric.clientState2.updateGameLighting();
    }
  }

  static void onChangedGameTimeEnabled(bool value){
    GameUI.timeVisible.value = value;
  }
}