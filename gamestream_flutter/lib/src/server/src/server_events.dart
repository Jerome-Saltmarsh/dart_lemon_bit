
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/library.dart';

class ServerEvents {

  static void onChangedAreaType(int areaType) {
     gamestream.games.isometric.clientState.areaTypeVisible.value = true;
  }

  static void onChangedLightningFlashing(bool lightningFlashing){
    if (lightningFlashing) {
      gamestream.audio.thunder(1.0);
    } else {
      gamestream.games.isometric.clientState.updateGameLighting();
    }
  }

  static void onChangedGameTimeEnabled(bool value){
    GameIsometricUI.timeVisible.value = value;
  }
}