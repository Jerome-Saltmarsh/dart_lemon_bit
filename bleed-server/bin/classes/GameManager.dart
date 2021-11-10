import '../compile.dart';
import 'Game.dart';

class GameManager {
  List<Game> games = [];

  void compileAndAddGame(Game game) {
    compileGame(game);
    game.compiledTiles = compileTiles(game.scene.tiles);
    game.compiledEnvironmentObjects = compileEnvironmentObjects(game.scene.environment);
    games.add(game);
  }
}
