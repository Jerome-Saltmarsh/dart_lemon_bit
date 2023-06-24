import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_events.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_power.dart';
import 'package:gamestream_flutter/gamestream/server_response_reader.dart';
import 'package:gamestream_flutter/library.dart';

import 'package:gamestream_flutter/gamestream/gamestream.dart';

extension CaptureTheFlagResponseReader on Gamestream {

  void readCaptureTheFlag() {
    final captureTheFlag = gamestream.games.captureTheFlag;
    switch (readByte()) {
      case CaptureTheFlagResponse.Score:
        captureTheFlag.scoreRed.value = readUInt16();
        captureTheFlag.scoreBlue.value = readUInt16();
        break;
      case CaptureTheFlagResponse.Flag_Positions:
        readVector3(captureTheFlag.flagPositionRed);
        readVector3(captureTheFlag.flagPositionBlue);
        break;
      case CaptureTheFlagResponse.Base_Positions:
        readVector3(captureTheFlag.basePositionRed);
        readVector3(captureTheFlag.basePositionBlue);
        break;
      case CaptureTheFlagResponse.Flag_Status:
        captureTheFlag.flagRedStatus.value = readByte();
        captureTheFlag.flagBlueStatus.value = readByte();
        break;
      case CaptureTheFlagResponse.Red_Team_Scored:
        captureTheFlag.onRedTeamScore();
        break;
      case CaptureTheFlagResponse.Blue_Team_Scored:
        captureTheFlag.onBlueTeamScore();
        break;
      case CaptureTheFlagResponse.Player_Flag_Status:
        captureTheFlag.playerFlagStatus.value = readByte();
        break;
      case CaptureTheFlagResponse.Select_Class:
        captureTheFlag.selectClass.value = readBool();
        break;
      case CaptureTheFlagResponse.Game_Status:
        captureTheFlag.gameStatus.value = CaptureTheFlagGameStatus.values[readByte()];
        break;
      case CaptureTheFlagResponse.Next_Game_Count_Down:
        captureTheFlag.nextGameCountDown.value = readUInt16();
        break;

      case CaptureTheFlagResponse.Activated_Power:
        final powerSet = readBool();
        if (!powerSet) {
          captureTheFlag.playerActivatedPowerType.value = null;
        } else {
          captureTheFlag.playerActivatedPowerType.value = readPowerType();
          captureTheFlag.playerActivatedPowerRange.value = readUInt16().toDouble();
        }
        break;

      case CaptureTheFlagResponse.Activated_Power_Position:
        captureTheFlag.playerActivatedPowerX.value = readUInt24().toDouble();
        captureTheFlag.playerActivatedPowerY.value = readUInt24().toDouble();
        break;

      case CaptureTheFlagResponse.Activated_Power_Target:
        final playerActivatedTargetPositionSet = readBool();;
        captureTheFlag.playerActivatedTargetSet = playerActivatedTargetPositionSet;
        if (!playerActivatedTargetPositionSet)
          break;

        readIsometricPosition(captureTheFlag.playerActivatedTarget);
        break;

      case CaptureTheFlagResponse.Power_1:
        readPower(captureTheFlag.playerPower1);
        break;

      case CaptureTheFlagResponse.Power_2:
        readPower(captureTheFlag.playerPower2);
        break;

      case CaptureTheFlagResponse.Power_3:
        readPower(captureTheFlag.playerPower3);
        break;

      case CaptureTheFlagResponse.Player_Experience:
        captureTheFlag.playerExperience.value = readUInt24();
        break;

      case CaptureTheFlagResponse.Player_Level:
        captureTheFlag.playerLevel.value = readByte();
        captureTheFlag.playerExperienceRequiredForNextLevel.value = readUInt24();
        captureTheFlag.skillPoints.value = readByte();
        break;

      case CaptureTheFlagResponse.Player_Event_Level_Gained:
        captureTheFlag.audioOnLevelGain.play();
        gamestream.isometric.clientState.spawnConfettiPlayer();
        break;

      case CaptureTheFlagResponse.Player_Event_Skill_Upgraded:
        captureTheFlag.audioOnLevelGain.play();
        gamestream.isometric.clientState.spawnConfettiPlayer();
        break;
    }
  }

  void readPower(CaptureTheFlagPower power){
    power.type.value = readPowerType();
    power.cooldown.value = readUInt16();
    power.cooldownRemaining.value = readUInt16();
    power.activated.value = readBool();
    power.level.value = readByte();
  }

  CaptureTheFlagPowerType readPowerType() =>
      CaptureTheFlagPowerType.values[readByte()];

}