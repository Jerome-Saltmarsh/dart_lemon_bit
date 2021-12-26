import 'package:bleed_server/CubeGame.dart';

import 'classes/Game.dart';
import 'classes/Player.dart';
import 'compile.dart';
import 'games/Royal.dart';
import 'games/Moba.dart';
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

  Royal findPendingHunterGame() {
    for (Game game in global.games) {
      if (game is Royal) {
        if (game.awaitingPlayers) {
          return game;
        }
      }
    }
    return Royal();
  }


  void onGameCreated(Game game) {
    compileGame(game);
    game.compiledTiles = compileTiles(game.scene.tiles);
    game.compiledEnvironmentObjects =
        compileEnvironmentObjects(game.scene.environment);
    games.add(game);
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
