
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_team.dart';
import 'package:bleed_server/common/src/game_type.dart';
import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_player.dart';
import 'package:bleed_server/src/games/isometric/isometric_game.dart';

class CaptureTheFlagGame extends IsometricGame<CaptureTheFlagPlayer> {

  late final flagRed = spawnGameObject(x: 0, y: 0, z: 0, type: ItemType.GameObjects_Flag_Red);
  late final flagBlue = spawnGameObject(x: 0, y: 0, z: 0, type: ItemType.GameObjects_Flag_Blue);

  int get countPlayersOnTeamRed => countPlayersOnTeam(CaptureTheFlagTeam.Red);
  int get countPlayersOnTeamBlue => countPlayersOnTeam(CaptureTheFlagTeam.Blue);

  int countPlayersOnTeam(int team) =>
      players.where((player) => player.team == team).length;

  CaptureTheFlagGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Capture_The_Flag);

  @override
  void customWriteGame() {
  }

  @override
  CaptureTheFlagPlayer buildPlayer() {
    final player = CaptureTheFlagPlayer(game: this);
    player.team = countPlayersOnTeamBlue > countPlayersOnTeamRed
        ? CaptureTheFlagTeam.Red
        : CaptureTheFlagTeam.Blue;
    player.x = 100;
    player.y = 100;
    player.z = 50;
    return player;
  }

  @override
  int get maxPlayers => 8;
}