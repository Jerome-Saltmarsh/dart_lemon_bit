import 'capture_the_flag_game.dart';
import 'package:gamestream_flutter/common.dart';

extension CaptureTheFlagProperties on CaptureTheFlagGame {
  bool get playerIsTeamRed => player.team.value == CaptureTheFlagTeam.Red;
  bool get playerIsTeamBlue => player.team.value == CaptureTheFlagTeam.Blue;
  bool get teamFlagIsAtBase => flagStatusAlly == CaptureTheFlagFlagStatus.At_Base;
  int get flagStatusAlly => playerIsTeamRed ? flagRedStatus.value : flagBlueStatus.value;
  int get flagStatusEnemy => playerIsTeamRed ? flagBlueStatus.value : flagRedStatus.value;
}
