
import 'package:bleed_server/gamestream.dart';

class Game5v5 extends Game {

  static const Player_Per_Team = 5;
  var started = false;

  Game5v5(super.scene);

  @override
  int get gameType => GameType.FiveVFive;

  @override
  void customOnPlayerJoined(Player player) {
    print("customOnPlayerJoined 5v5");
    assert(!started);

    if (players.length == Player_Per_Team * 2) {
      started = true;
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