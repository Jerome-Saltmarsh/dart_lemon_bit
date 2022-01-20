import 'package:bleed_server/CubeGame.dart';

import 'classes/Game.dart';
import 'classes/Player.dart';
import 'common/GameStatus.dart';
import 'compile.dart';
import 'games/Royal.dart';
import 'games/Moba.dart';
import 'games/world.dart';
import 'settings.dart';

final _Global global = _Global();

class _Global {
  final List<Game> games = [];

  Moba findPendingMobaGame() {
    for (Game game in global.games) {
      if (game is Moba) {
        if (game.awaitingPlayers) {
          return game;
        }
      }
    }
    return Moba();
  }

  GameRoyal findPendingRoyalGames() {
    return findGameAwaitingPlayers<GameRoyal>() ?? GameRoyal();
  }

  T? findGameAwaitingPlayers<T extends Game>() {
    for (Game game in global.games) {
      if (game is T == false) continue;
      if (!game.awaitingPlayers) continue;
      return game as T;
    }
    return null;
  }

  // This method is called by the game constructor automatically
  // and should not be called again
  void onGameCreated(Game game) {
    compileGame(game);
    game.compiledTiles = compileTiles(game.scene.tiles);
    game.compiledEnvironmentObjects =
        compileEnvironmentObjects(game.scene.environment);
    games.add(game);
  }

  void onPlayerCreated(Player player){
    player.game.players.add(player);
    registerPlayer(player);
  }

  void update() {

    // cubeGame.update();

    for (Game game in games) {

      switch(game.status) {

        case GameStatus.Awaiting_Players:
          for (int i = 0; i < game.players.length; i++) {
            Player player = game.players[i];
            player.lastUpdateFrame++;
            if (player.lastUpdateFrame > settings.framesUntilPlayerDisconnected) {
              game.players.removeAt(i);
              i--;
            }
          }
          break;

        case GameStatus.Counting_Down:
          game.countDownFramesRemaining--;
          if (game.countDownFramesRemaining <= 0) {
            game.status = GameStatus.In_Progress;
            game.onGameStarted();
          }
          break;

        case GameStatus.In_Progress:
          game.updateAndCompile();
          break;

        case GameStatus.Finished:
          break;
      }
    }
  }
}
