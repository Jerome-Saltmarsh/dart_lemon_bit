import 'package:gamestream_flutter/library.dart';

import 'capture_the_flag_game.dart';
import 'capture_the_flag_properties.dart';

extension CaptureTheFlagEvents on CaptureTheFlagGame {
  void onChangedFlagRedStatus(int flagStatus) {
    if (playerIsTeamRed) {
      switch (flagStatus) {
        case CaptureTheFlagFlagStatus.Carried_By_Ally:
          isometric.audio.voiceYourTeamHasYourFlag.play();
          break;
        case CaptureTheFlagFlagStatus.Carried_By_Enemy:
          isometric.audio.voiceTheEnemyHasYourFlag.play();
          break;
        case CaptureTheFlagFlagStatus.At_Base:
          isometric.audio.voiceYourFlagIsAtYourBase.play();
          break;
        case CaptureTheFlagFlagStatus.Dropped:
          isometric.audio.voiceYourFlagHasBeenDropped.play();
          break;
      }
      return;
    }

    assert (playerIsTeamBlue);

    switch (flagStatus) {
      case CaptureTheFlagFlagStatus.Carried_By_Ally:
        isometric.audio.voiceTheEnemyHasTheirFlag.play();
        break;
      case CaptureTheFlagFlagStatus.Carried_By_Enemy:
        isometric.audio.voiceYourTeamHasTheEnemyFlag.play();
        break;
      case CaptureTheFlagFlagStatus.At_Base:
        isometric.audio.voiceTheEnemyFlagIsAtTheirBase.play();
        break;
      case CaptureTheFlagFlagStatus.Dropped:
        isometric.audio.voiceTheEnemyFlagHasBeenDropped.play();
        break;
    }
  }

  void onChangedFlagBlueStatus(int flagStatus) {
    if (playerIsTeamBlue) {
      switch (flagStatus) {
        case CaptureTheFlagFlagStatus.Carried_By_Ally:
          isometric.audio.voiceYourTeamHasYourFlag.play();
          break;
        case CaptureTheFlagFlagStatus.Carried_By_Enemy:
          isometric.audio.voiceTheEnemyHasYourFlag.play();
          break;
        case CaptureTheFlagFlagStatus.At_Base:
          isometric.audio.voiceYourFlagIsAtYourBase.play();
          break;
        case CaptureTheFlagFlagStatus.Dropped:
          isometric.audio.voiceYourFlagHasBeenDropped.play();
          break;
      }
      return;
    }

    assert (playerIsTeamRed);

    switch (flagStatus) {
      case CaptureTheFlagFlagStatus.Carried_By_Ally:
        isometric.audio.voiceTheEnemyHasTheirFlag.play();
        break;
      case CaptureTheFlagFlagStatus.Carried_By_Enemy:
        isometric.audio.voiceYourTeamHasTheEnemyFlag.play();
        break;
      case CaptureTheFlagFlagStatus.At_Base:
        isometric.audio.voiceTheEnemyFlagIsAtTheirBase.play();
        break;
      case CaptureTheFlagFlagStatus.Dropped:
        isometric.audio.voiceTheEnemyFlagHasBeenDropped.play();
        break;
    }
  }

  void onRedTeamScore(){
    print('onRedTeamScore()');
    if (playerIsTeamRed){
      isometric.audio.voiceYourTeamHasScoredAPoint.play();
    } else {
      isometric.audio.voiceTheEnemyHasScored.play();
    }
  }

  void onBlueTeamScore() {
    print('onBlueTeamScore()');
    if (playerIsTeamBlue){
      isometric.audio.voiceYourTeamHasScoredAPoint.play();
    } else {
      isometric.audio.voiceTheEnemyHasScored.play();
    }
  }
}