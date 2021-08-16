import '../enums/GameType.dart';
import '../instances/scenes.dart';
import '../utils.dart';
import 'Block.dart';
import 'Game.dart';
import 'Scene.dart';

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

  Scene buildOpenWorldScene() {
    List<Block> blocks = [];
    blocks.add(Block.build(50, 800, 200, 150));
    Scene scene = Scene(generateTiles(), blocks, [], [], []);
    scene.sortBlocks();
    return scene;
  }

  Game getAvailableDeathMatch() {
    for (Game game in games) {
      if (game.type != GameType.DeathMatch) continue;
      if (game.players.length < game.maxPlayers) {
        return game;
      }
    }

    Game deathMatch = Game(GameType.DeathMatch, scenesTown, 16);
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
    Game deathMatch = Game(GameType.OpenWorld, buildOpenWorldScene(), 64);
    games.add(deathMatch);
    return deathMatch;
  }
}
