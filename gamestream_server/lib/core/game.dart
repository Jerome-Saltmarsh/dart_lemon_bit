import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/core/player.dart';
import 'package:gamestream_server/core/job.dart';
import 'package:gamestream_server/gamestream.dart';

abstract class Game <T extends Player> {
  var playerId = 0;
  final GameType gameType;
  final List<T> players = [];
  final jobs = <GameJob>[];

  int get maxPlayers;
  bool get isFull => players.length >= maxPlayers;

  int get fps => Gamestream.Frames_Per_Second;

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
    required bool keyDownShift,
  });

  void writePlayerResponses() {
    for (var i = 0; i < players.length; i++) {
      final player = players[i];
      player.writePlayerGame();
      customWriteGame();
    }
  }

  void removePlayer(T player);

  void addJob({
    required num seconds,
    required Function action,
    bool repeat = false,
  }) {
    final frames = (fps * seconds).toInt();
     for (final job in jobs){
         if (job.repeat) continue;
         if (job.remaining > 0) continue;
         job.remaining = frames;
         job.duration = frames;
         job.action = action;
         job.repeat = repeat;
         return;
     }
     jobs.add(GameJob(frames, action, repeat: repeat));
  }

  void updateJobs() {
    for (var i = 0; i < jobs.length; i++) {
      final job = jobs[i];
      if (job.remaining <= 0) continue;
      job.remaining--;
      if (job.remaining > 0) continue;
      job.action();
      if (job.repeat) {
        job.remaining = job.duration;
      } else {
        job.action = _clearJob;
      }
    }
  }

  void _clearJob(){}

}

