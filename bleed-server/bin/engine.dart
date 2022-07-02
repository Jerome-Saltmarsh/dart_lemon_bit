import 'dart:async';

import 'classes/library.dart';
import 'constants/frames_per_second.dart';
import 'games/game_frontline.dart';
import 'io/read_scene_from_file.dart';
import 'isometric/generate_empty_grid.dart';
import 'language.dart';

final engine = _Engine();

class _Engine {
  final games = <Game>[];
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

    if (frame % 30 == 0) {
      for (final game in games) {
        game.updateAIPath();
      }
    }

    // if (frame % framesPerSecond == 0){
    //    for (final game in games) {
    //      if (game is GameRandom == false) continue;
    //      game.writePlayerCooldowns();
    //    }
    // }

    for (final game in games) {
      game.updateStatus();
    }
  }

  Future<GameDarkAge> findGameFrontLine() async {
    for (final game in games) {
      if (game is GameDarkAge) {
        if (game.full) continue;
        return game;
      }
    }
    final scene = await readSceneFromFile('castle');
    return GameDarkAge(scene);
  }

  Future<GameDarkAge> findGameEditor() async {
    final game = GameDarkAge(Scene(
      gameObjects: [],
      characters: [],
      enemySpawns: [],
      grid: generateEmptyGrid(
        zHeight: 8,
        rows: 50,
        columns: 50,
      ),
    ));
    games.add(game);
    return game;
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
