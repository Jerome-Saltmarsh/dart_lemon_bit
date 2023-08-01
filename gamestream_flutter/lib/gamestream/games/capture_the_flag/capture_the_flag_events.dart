import 'package:gamestream_flutter/library.dart';

import 'capture_the_flag_game.dart';
import 'capture_the_flag_properties.dart';

extension CaptureTheFlagEvents on CaptureTheFlagGame {
  void onChangedFlagRedStatus(int flagStatus) {
    if (playerIsTeamRed) {
      switch (flagStatus) {
        case CaptureTheFlagFlagStatus.Carried_By_Ally:
          audio.voiceYourTeamHasYourFlag.play();
          break;
        case CaptureTheFlagFlagStatus.Carried_By_Enemy:
          audio.voiceTheEnemyHasYourFlag.play();
          break;
        case CaptureTheFlagFlagStatus.At_Base:
          audio.voiceYourFlagIsAtYourBase.play();
          break;
        case CaptureTheFlagFlagStatus.Dropped:
          audio.voiceYourFlagHasBeenDropped.play();
          break;
      }
      return;
    }

    assert (playerIsTeamBlue);

    switch (flagStatus) {
      case CaptureTheFlagFlagStatus.Carried_By_Ally:
        audio.voiceTheEnemyHasTheirFlag.play();
        break;
      case CaptureTheFlagFlagStatus.Carried_By_Enemy:
        audio.voiceYourTeamHasTheEnemyFlag.play();
        break;
      case CaptureTheFlagFlagStatus.At_Base:
        audio.voiceTheEnemyFlagIsAtTheirBase.play();
        break;
      case CaptureTheFlagFlagStatus.Dropped:
        audio.voiceTheEnemyFlagHasBeenDropped.play();
        break;
    }
  }

  void onChangedFlagBlueStatus(int flagStatus) {
    if (playerIsTeamBlue) {
      switch (flagStatus) {
        case CaptureTheFlagFlagStatus.Carried_By_Ally:
          audio.voiceYourTeamHasYourFlag.play();
          break;
        case CaptureTheFlagFlagStatus.Carried_By_Enemy:
          audio.voiceTheEnemyHasYourFlag.play();
          break;
        case CaptureTheFlagFlagStatus.At_Base:
          audio.voiceYourFlagIsAtYourBase.play();
          break;
        case CaptureTheFlagFlagStatus.Dropped:
          audio.voiceYourFlagHasBeenDropped.play();
          break;
      }
      return;
    }

    assert (playerIsTeamRed);

    switch (flagStatus) {
      case CaptureTheFlagFlagStatus.Carried_By_Ally:
        audio.voiceTheEnemyHasTheirFlag.play();
        break;
      case CaptureTheFlagFlagStatus.Carried_By_Enemy:
        audio.voiceYourTeamHasTheEnemyFlag.play();
        break;
      case CaptureTheFlagFlagStatus.At_Base:
        audio.voiceTheEnemyFlagIsAtTheirBase.play();
        break;
      case CaptureTheFlagFlagStatus.Dropped:
        audio.voiceTheEnemyFlagHasBeenDropped.play();
        break;
    }
  }

  void onRedTeamScore(){
    print('onRedTeamScore()');
    if (playerIsTeamRed){
      audio.voiceYourTeamHasScoredAPoint.play();
    } else {
      audio.voiceTheEnemyHasScored.play();
    }
  }

  void onBlueTeamScore() {
    print('onBlueTeamScore()');
    if (playerIsTeamBlue){
      audio.voiceYourTeamHasScoredAPoint.play();
    } else {
      audio.voiceTheEnemyHasScored.play();
    }
  }
}