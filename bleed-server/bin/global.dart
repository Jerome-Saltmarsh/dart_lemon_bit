import 'package:bleed_server/CubeGame.dart';

import 'classes/Game.dart';
import 'classes/Player.dart';
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

  Royal findPendingRoyalGames() {
    return findGameAwaitingPlayers<Royal>() ?? Royal();
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

    cubeGame.update();

    for (Game game in games) {
      if (game.awaitingPlayers) {
        for (int i = 0; i < game.players.length; i++) {
          Player player = game.players[i];
          player.lastUpdateFrame++;
          if (player.lastUpdateFrame > settings.framesUntilPlayerDisconnected) {
            game.players.removeAt(i);
            i--;
          }
        }
      }
      if (!game.inProgress) continue;
      game.updateAndCompile();
    }
  }
}
