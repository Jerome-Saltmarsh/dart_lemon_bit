import '../utils.dart';
import 'Game.dart';

class GameManager {
  List<Game> games = [];
  Game openWorldGame = Game();

  GameManager() {
    generateTiles(openWorldGame);
    games.add(openWorldGame);
  }

  Game? findGameById(String id) {
    for (Game game in games) {
      if (game.id == id) {
        return game;
      }
    }
    return null;
  }
}

extension GameManagerFunctions on GameManager {
  Game createGame() {
    Game game = Game();
    generateTiles(game);
    games.add(game);
    return game;
  }

  void updateAndCompileGames() {
    games.forEach((game) => game.updateAndCompile());
  }
}
