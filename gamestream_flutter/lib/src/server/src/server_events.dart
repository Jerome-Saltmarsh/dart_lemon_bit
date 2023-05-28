
import 'package:gamestream_flutter/engine/instances.dart';
import 'package:gamestream_flutter/library.dart';

class ServerEvents {

  static void onChangedAreaType(int areaType) {
     ClientState.areaTypeVisible.value = true;
  }

  static void onChangedLightningFlashing(bool lightningFlashing){
    if (lightningFlashing) {
      gamestream.audio.thunder(1.0);
    } else {
      ClientState.updateGameLighting();
    }
  }

  static void onChangedGameTimeEnabled(bool value){
    GameUI.timeVisible.value = value;
  }
}