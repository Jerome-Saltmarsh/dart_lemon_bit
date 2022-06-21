import 'dart:async';

import 'classes/library.dart';
import 'common/library.dart';
import 'constants/frames_per_second.dart';
import 'games/game_frontline.dart';
import 'io/read_scene_from_file.dart';
import 'language.dart';

final engine = _Engine();

class _Engine {
  final games = <Game>[];
  final scenes = _Scenes();
  late final world;
  var frame = 0;

  Future init() async {
    periodic(fixedUpdate, ms: 1000 ~/ framesPerSecond);
  }

  void fixedUpdate(Timer timer) {
    frame++;

    if (frame % 5 == 0) {
      games.removeWhere((game) => game.finished);

      for (var i = 0; i < games.length; i++) {
        final game = games[i];
        if (game.disableCountDown < 15) continue;
        assert(game.players.isEmpty);
        games.removeAt(i);
        i--;
      }
    }

    const framesPerRegen = framesPerSecond * 10;
    if (frame % framesPerRegen == 0) {
      for (final game in games) {
        game.regenCharacters();
      }
    }

    // if (frame % 30 == 0) {
    //   for (final game in games) {
    //     game.updateAIPath();
    //   }
    // }

    // if (frame % framesPerSecond == 0){
    //    for (final game in games) {
    //      if (game is GameRandom == false) continue;
    //      game.writePlayerCooldowns();
    //    }
    // }

    for (final game in games) {
     game.removeDisconnectedPlayers();
      switch(game.status) {

        case GameStatus.In_Progress:
          game.updateInProgress();
          break;

        case GameStatus.Awaiting_Players:
          for (int i = 0; i < game.players.length; i++) {
            final player = game.players[i];
            player.lastUpdateFrame++;
            if (player.lastUpdateFrame > 100) {
              game.players.removeAt(i);
              i--;
            }
          }
          break;

        case GameStatus.Counting_Down:
          game.countDownFramesRemaining--;
          if (game.countDownFramesRemaining <= 0) {
            game.setGameStatus(GameStatus.In_Progress);
            game.onGameStarted();
          }
          break;

        default:
          break;
      }
    }

    for (final game in games) {
      final players = game.players;
      for (final player in players) {
        player.writePlayerGame();
        player.writeByte(ServerResponse.End);
        player.sendBufferToClient();
      }
    }
  }

  Future<GameFrontline> findGameFrontLine() async {
    for (final game in games) {
      if (game is GameFrontline) {
        if (game.full) continue;
        return game;
      }
    }
    final scene = await readSceneFromFile('castle');
    return GameFrontline(scene);
  }


  T? findGameAwaitingPlayers<T extends Game>() {
    for (final game in games) {
      if (game is T == false) continue;
      if (!game.awaitingPlayers) continue;
      return game as T;
    }
    return null;
  }

  // This method is called by the game constructor automatically
  // and should not be called again
  void onGameCreated(Game game) {
    games.add(game);
  }

  void onPlayerCreated(Player player) {
    player.game.players.add(player);
    player.game.disableCountDown = 0;
  }
}

class _Scenes {
  late Scene town;
  late Scene tavern;
  late Scene wildernessWest01;
  late Scene wildernessNorth01;
  late Scene cave;
  late Scene wildernessEast;
  late Scene royal;
  late Scene skirmish;

  // Future load() async {
  //   print("loadScenes()");
  //   town = await loadSceneFromFile('town');
  //   tavern = await loadSceneFromFile('tavern');
  //   cave = await loadSceneFromFile('cave');
  //   wildernessWest01 = await loadSceneFromFile('wilderness-west-01');
  //   wildernessNorth01 = await loadSceneFromFile('wilderness-north-01');
  //   wildernessEast = await loadSceneFromFile('wilderness-east');
  //   // royal = await loadSceneFromFireStore('royal');
  //   skirmish = await loadSceneFromFireStore('skirmish');
  // }
}