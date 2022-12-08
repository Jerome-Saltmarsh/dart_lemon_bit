
import 'package:bleed_server/gamestream.dart';

class Game5v5 extends Game {

  static const Player_Per_Team = 1;
  static const Total_Players = Player_Per_Team * 2;

  var gameStatus = GameStatus.Waiting_For_Players;
  var spawnPoint1 = 0;
  var spawnPoint2 = 1;

  bool get started => gameStatus == GameStatus.Playing;

  Game5v5(super.scene) {
    if (scene.spawnPointsPlayers.length >= 2) {
      spawnPoint1 = scene.spawnPointsPlayers[0];
      spawnPoint2 = scene.spawnPointsPlayers[1];
    }
  }

  @override
  int get gameType => GameType.FiveVFive;

  @override
  void customOnPlayerJoined(Player player) {
    assert(!started);

    if (players.length == Player_Per_Team * 2) {
      start();
    } else {
      player.writeGameStatus(GameStatus.Waiting_For_Players);
    }
  }

  void start(){
    assert(players.length == Total_Players);
    gameStatus = GameStatus.Playing;

    for (var i = 0; i < Player_Per_Team; i++){
      final player = players[i];
      player.team = 1;
      moveToIndex(player, spawnPoint1);
    }
    for (var i = Player_Per_Team; i < Total_Players; i++){
      final player = players[i];
      player.team = 2;
      moveToIndex(player, spawnPoint2);
    }
    playersWriteGameStatus(GameStatus.Playing);
  }

  @override
  void customOnCharacterKilled(Character target, dynamic src) {
     if (target is Player){
        onPlayerKilled(target);
     }
  }

  void onPlayerKilled(Player player){

  }

  @override
  void revive(Player player) {
     player.writeError('cannot revive');
  }
}