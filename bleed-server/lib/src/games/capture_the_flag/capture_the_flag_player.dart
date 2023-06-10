
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_player_status.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:bleed_server/src/games/isometric/isometric_player.dart';
import 'package:bleed_server/src/utilities/change_notifier.dart';

class CaptureTheFlagPlayer extends IsometricPlayer {

  @override
  final CaptureTheFlagGame game;

  late final flagStatus = ChangeNotifier(
      CaptureTheFlagPlayerStatus.No_Flag,
      writePlayerFlagStatus,
  );

  bool get isTeamRed => team == CaptureTheFlagTeam.Red;
  bool get isTeamBlue => team == CaptureTheFlagTeam.Blue;

  CaptureTheFlagPlayer({required this.game}) : super(game: game) {
    writeScore();
  }

  @override
  void writePlayerGame() {
    super.writePlayerGame();
    writeFlagPositions(); // todo optimize
    writeBasePositions(); // todo optimize
  }

  void writeFlagPositions() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Flag_Positions);
    writeIsometricPosition(game.flagRed);
    writeIsometricPosition(game.flagBlue);
  }

  void writeBasePositions() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Base_Positions);
    writeIsometricPosition(game.baseRed);
    writeIsometricPosition(game.baseBlue);
  }

  void writePlayerFlagStatus() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Player_Flag_Status);
    writeByte(flagStatus.value);
  }

  void writeScore() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Score);
    writeUInt16(game.scoreRed.value);
    writeUInt16(game.scoreBlue.value);
  }

  void writeFlagStatus() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Flag_Status);
    writeByte(game.flagRed.status);
    writeByte(game.flagBlue.status);
  }

  void setFlagStatusNoFlag(){
     flagStatus.value = CaptureTheFlagPlayerStatus.No_Flag;
  }

  void setFlagStatusHoldingEnemyFlag(){
    flagStatus.value = CaptureTheFlagPlayerStatus.Holding_Enemy_Flag;
  }
}