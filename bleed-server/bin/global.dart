import 'classes/Game.dart';
import 'compile.dart';
import 'games/moba.dart';

final _Global global = _Global();

class _Global {
  List<Game> games = [];

  Moba findPendingMobaGame() {
    for (Game game in global.games) {
      if (game is Moba){
        if (game.status == GameStatus.Awaiting_Players) {
          return game;
        }
      }
    }
    return Moba();
  }

  void onGameCreated(Game game){
    compileGame(game);
    game.compiledTiles = compileTiles(game.scene.tiles);
    game.compiledEnvironmentObjects = compileEnvironmentObjects(game.scene.environment);
    games.add(game);
  }

  void update(){
    for (Game game in games) {
      if (!game.inProgress) continue;
      game.updateAndCompile();
    }
  }
}

