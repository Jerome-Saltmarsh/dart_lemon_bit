import 'package:bleed_common/src/capture_the_flag/src.dart';
import 'package:gamestream_flutter/library.dart';

import 'capture_the_flag_game.dart';

extension CaptureTheFlagEvents on CaptureTheFlagGame {
  void onChangedFlagRedStatus(int flagStatus) {
    if (playerIsTeamRed) {
      switch (flagStatus) {
        case CaptureTheFlagFlagStatus.Carried_By_Allie:
          gamestream.audio.voiceYourTeamHasYourFlag.play();
          break;
        case CaptureTheFlagFlagStatus.Carried_By_Enemy:
          gamestream.audio.voiceTheEnemyHasYourFlag.play();
          break;
        case CaptureTheFlagFlagStatus.At_Base:
          gamestream.audio.voiceYourFlagIsAtYourBase.play();
          break;
        case CaptureTheFlagFlagStatus.Dropped:
          gamestream.audio.voiceYourFlagHasBeenDropped.play();
          break;
      }
      return;
    }

    assert (playerIsTeamBlue);

    switch (flagStatus) {
      case CaptureTheFlagFlagStatus.Carried_By_Allie:
        gamestream.audio.voiceTheEnemyHasTheirFlag.play();
        break;
      case CaptureTheFlagFlagStatus.Carried_By_Enemy:
        gamestream.audio.voiceYourTeamHasTheEnemyFlag.play();
        break;
      case CaptureTheFlagFlagStatus.At_Base:
        gamestream.audio.voiceTheEnemyFlagIsAtTheirBase.play();
        break;
      case CaptureTheFlagFlagStatus.Dropped:
        gamestream.audio.voiceTheEnemyFlagHasBeenDropped.play();
        break;
    }
  }

  void onChangedFlagBlueStatus(int flagStatus) {
    if (playerIsTeamBlue) {
      switch (flagStatus) {
        case CaptureTheFlagFlagStatus.Carried_By_Allie:
          gamestream.audio.voiceYourTeamHasYourFlag.play();
          break;
        case CaptureTheFlagFlagStatus.Carried_By_Enemy:
          gamestream.audio.voiceTheEnemyHasYourFlag.play();
          break;
        case CaptureTheFlagFlagStatus.At_Base:
          gamestream.audio.voiceYourFlagIsAtYourBase.play();
          break;
        case CaptureTheFlagFlagStatus.Dropped:
          gamestream.audio.voiceYourFlagHasBeenDropped.play();
          break;
      }
      return;
    }

    assert (playerIsTeamRed);

    switch (flagStatus) {
      case CaptureTheFlagFlagStatus.Carried_By_Allie:
        gamestream.audio.voiceTheEnemyHasTheirFlag.play();
        break;
      case CaptureTheFlagFlagStatus.Carried_By_Enemy:
        gamestream.audio.voiceYourTeamHasTheEnemyFlag.play();
        break;
      case CaptureTheFlagFlagStatus.At_Base:
        gamestream.audio.voiceTheEnemyFlagIsAtTheirBase.play();
        break;
      case CaptureTheFlagFlagStatus.Dropped:
        gamestream.audio.voiceTheEnemyFlagHasBeenDropped.play();
        break;
    }
  }

  void onRedTeamScore(){
    print("onRedTeamScore()");
    if (playerIsTeamRed){
      gamestream.audio.voiceYourTeamHasScoredAPoint.play();
    } else {
      gamestream.audio.voiceTheEnemyHasScored.play();
    }
  }

  void onBlueTeamScore() {
    print("onBlueTeamScore()");
    if (playerIsTeamBlue){
      gamestream.audio.voiceYourTeamHasScoredAPoint.play();
    } else {
      gamestream.audio.voiceTheEnemyHasScored.play();
    }
  }
}