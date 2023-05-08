
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/touch_controller.dart';

class ServerEvents {

  static void onChangedAreaType(int areaType) {
     ClientState.areaTypeVisible.value = true;
  }

  static void onChangedGameType(int? value) {
    if (value == GameType.Rock_Paper_Scissors){
      GameScissorsPaperRock.init();
      return;
    }

    ClientState.edit.value = value == GameType.Editor;

    if (value != GameType.Combat) {
      ClientState.window_visible_player_creation.value = false;
      ClientState.control_visible_respawn_timer.value = false;
      GameAudio.musicStop();
    } else {
      GameAudio.musicPlay();
    }

    Engine.onLeftClicked = TouchController.onClick;
    Engine.onMouseMoved = TouchController.onMouseMoved;
    ClientState.control_visible_player_weapons.value  = value == GameType.Combat;
    ClientState.control_visible_scoreboard.value      = value == GameType.Combat;
    ClientState.control_visible_player_power.value    = value == GameType.Combat;

    if (value == null) {
      GameAudio.musicStop();
      Engine.fullScreenExit();
    }

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