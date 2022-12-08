
import 'package:bleed_server/common/src/enums/game_status.dart';
import 'package:bleed_server/gamestream.dart';

class Game5v5 extends Game {

  static const Player_Per_Team = 5;
  static const Total_Players = Player_Per_Team * 2;
  var started = false;

  Game5v5(super.scene) {
    // assert(scene.tags.containsKey(TagType.Team_Spawn_1));
    // assert(scene.tags.containsKey(TagType.Team_Spawn_2));
  }

  @override
  int get gameType => GameType.FiveVFive;

  @override
  void customOnPlayerJoined(Player player) {
    assert(!started);

    if (players.length == Player_Per_Team * 2) {
      started = true;
      playersWriteGameStatus(GameStatus.Playing);
    } else {
      player.writeGameStatus(GameStatus.Waiting_For_Players);
    }
  }

  void start(){
    assert(players.length == Total_Players);
    started = true;

    for (var i = 0; i < Player_Per_Team; i++){
      final player = players[i];

    }
    for (var i = Player_Per_Team; i < Total_Players; i++){

    }

    for (final player in players) {
      // player.writeByte(ServerResponse.Game_State);
      // player.writeByte(GameState.In_Progress);
    }
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