
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_response.dart';
import 'package:bleed_server/common/src/server_response.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:bleed_server/src/games/isometric/isometric_player.dart';

class CaptureTheFlagPlayer extends IsometricPlayer {

  @override
  final CaptureTheFlagGame game;

  CaptureTheFlagPlayer({required this.game}) : super(game: game) {
    writeScore();
  }

  @override
  void writePlayerGame() {
    super.writePlayerGame();
    writeFlagPositions();
  }

  void writeFlagPositions() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Flag_Positions);
    writeIsometricPosition(game.flagRed);
    writeIsometricPosition(game.flagBlue);
  }

  void writeScore() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Score);
    writeUInt16(game.scoreRed.value);
    writeUInt16(game.scoreBlue.value);
  }
}