import '../compile.dart';
import '../enums/GameType.dart';
import '../instances/scenes.dart';
import '../utils.dart';
import 'Block.dart';
import 'Game.dart';
import 'Lobby.dart';
import 'Scene.dart';

class GameManager {
  List<Game> games = [];
  List<Lobby> lobbies = [];

  Scene buildOpenWorldScene() {
    List<Block> blocks = [];
    blocks.add(Block.build(50, 800, 200, 150));
    Scene scene = Scene(generateTiles(), blocks);
    scene.sortBlocks();
    return scene;
  }

  Game getAvailableCasualGame() {
    for (Game game in games) {
      if (game.type != GameType.Casual) continue;
      if (game.players.length < game.maxPlayers) {
        return game;
      }
    }

    Game casualGame = GameCasual(scenes.town, 32);
    compileAndAddGame(casualGame);
    return casualGame;
  }

  void compileAndAddGame(Game game){
    compileGame(game);
    game.compiledTiles = compileTiles(StringBuffer(), game.scene.tiles);
    games.add(game);
  }

  Game? findAvailableGameByType(GameType type) {
    for (Game game in games) {
      if (game.type != GameType.OpenWorld) continue;
      if (game.players.length < game.maxPlayers) {
        return game;
      }
    }
    return null;
  }

  Lobby findAvailableDeathMatchLobby() {
    if (lobbies.isEmpty) return createDeathMatchLobby();

    for (Lobby lobby in lobbies) {
      if (lobby.game != null) continue;
      if (lobby.full) continue;
      return lobby;
    }

    return createDeathMatchLobby();
  }

  Lobby createDeathMatchLobby(){
    return createLobby(maxPlayer: 4, gameType: GameType.DeathMatch, private: false);
  }

  Lobby createLobby({required int maxPlayer, required GameType gameType, String? name, required bool private}) {
    print("create lobby(maxPlayers: $maxPlayer, type: $gameType, name: $name, private: $private)");
    Lobby lobby = Lobby(maxPlayers: maxPlayer, gameType: gameType, name: name, private: private);
    lobbies.add(lobby);
    return lobby;
  }


  DeathMatch createDeathMatch({int maxPlayer = 32}) {
    DeathMatch deathMatch = DeathMatch(maxPlayers: maxPlayer);
    compileAndAddGame(deathMatch);
    return deathMatch;
  }

  Fortress createGameFortress() {
    Fortress fortress = Fortress();
    compileAndAddGame(fortress);
    return fortress;
  }

  Fortress findOrCreateGameFortress() {
    Game? game = findAvailableGameByType(GameType.Fortress);
    if (game != null) return game as Fortress;
    return createGameFortress();
  }

  Game getAvailableOpenWorld() {
    for (Game game in games) {
      if (game.type != GameType.OpenWorld) continue;
      if (game.players.length < game.maxPlayers) {
        return game;
      }
    }
    Game openWorld = DeathMatch();
    compileAndAddGame(openWorld);
    return openWorld;
  }
}
