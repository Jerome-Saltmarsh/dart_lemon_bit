import 'package:bleed_server/common/src/game_type.dart';
import 'package:bleed_server/common/src/server_response.dart';
import 'package:bleed_server/src/game/player.dart';
import 'package:bleed_server/src/game/job.dart';

abstract class Game <T extends Player> {
  var playerId = 0;
  final GameType gameType;
  final List<T> players = [];
  final jobs = <GameJob>[];

  int get maxPlayers;
  bool get isFull => players.length >= maxPlayers;

  var _id = 0;

  int generateUniqueId() => _id++;

  Game({required this.gameType});

  void update() {

  }

  T createPlayer();

  void onPlayerJoined(T t) {

  }

  /// safe to override
  void customWriteGame(){

  }

  void onPlayerUpdateRequestReceived({
    required T player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool inputTypeKeyboard,
  });

  void writePlayerResponses() {
    for (var i = 0; i < players.length; i++) {
      final player = players[i];
      player.writePlayerGame();
      customWriteGame();
      player.writeByte(ServerResponse.End);
    }
  }

  void removePlayer(T player);

  void createJob({required int timer, required Function action}) {
     for (final job in jobs){
         if (job.timer > 0) continue;
         job.timer = timer;
         job.action = action;
         return;
     }
     jobs.add(GameJob(timer, action));
  }

  void updateJobs() {
    for (var i = 0; i < jobs.length; i++) {
      final job = jobs[i];
      if (job.timer <= 0) continue;
      job.timer--;
      if (job.timer > 0) continue;
      job.action();
      job.action = _clearJob;
    }
  }

  void _clearJob(){}

}

