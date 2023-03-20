
import 'package:gamestream_flutter/library.dart';

class ServerEvents {

  static void onChangedAreaType(int areaType) {
     ClientState.areaTypeVisible.value = true;
  }

  static void onChangedGameType(int? value){
    if (value == null) return;
    ClientState.edit.value = value == GameType.Editor;

    if (value != GameType.Combat){
      ClientState.window_visible_player_creation.value = false;
    }

    ClientState.control_visible_player_weapons.value = value == GameType.Combat;
    ClientState.control_visible_scoreboard.value = value == GameType.Combat;

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