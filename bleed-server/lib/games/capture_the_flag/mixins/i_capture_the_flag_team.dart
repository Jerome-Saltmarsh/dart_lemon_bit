import 'package:gamestream_server/common/src/capture_the_flag/capture_the_flag_team.dart';

mixin ICaptureTheFlagTeam {
  bool get isTeamRed => team == CaptureTheFlagTeam.Red;
  bool get isTeamBlue => team == CaptureTheFlagTeam.Blue;
  int get team;
}
