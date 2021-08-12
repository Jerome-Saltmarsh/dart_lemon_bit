import '../classes.dart';
import '../enums/GameType.dart';
import '../maths.dart';
import '../utils.dart';
import 'Block.dart';
import 'Game.dart';

class GameManager {
  List<Game> games = [];

  Game? findGameById(String id) {
    for (Game game in games) {
      if (game.id == id) {
        return game;
      }
    }
    return null;
  }

  Game getAvailableDeathMatch() {
    for (Game game in games) {
      if (game.type != GameType.DeathMatch) continue;
      if (game.players.length < game.maxPlayers) {
        return game;
      }
    }
    Game deathMatch = Game(GameType.DeathMatch, generateTiles(), 16);
    for (int i = 0; i < 3; i++) {
      deathMatch.blocks.add(Block(giveOrTake(500), 1000 + giveOrTake(500), 200 + giveOrTake(50), 100 + giveOrTake(50)));
    }
    deathMatch.sortBlocks();
    games.add(deathMatch);
    return deathMatch;
  }

  Game getAvailableOpenWorld() {
    for (Game game in games) {
      if (game.type != GameType.OpenWorld) continue;
      if (game.players.length < game.maxPlayers) {
        return game;
      }
    }
    Game deathMatch = Game(GameType.OpenWorld, generateTiles(), 64);
    games.add(deathMatch);
    return deathMatch;
  }
}
