import '../compile.dart';
import '../common/GameType.dart';
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

  void compileAndAddGame(Game game) {
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
    if (lobbies.isEmpty) return createLobbyDeathMatch();

    for (Lobby lobby in lobbies) {
      if (lobby.game != null) continue;
      if (lobby.full) continue;
      if (lobby.gameType != GameType.DeathMatch) continue;
      return lobby;
    }

    return createLobbyDeathMatch();
  }

  Lobby findAvailableLobbyFortress() {
    if (lobbies.isEmpty) return createLobbyFortress();

    for (Lobby lobby in lobbies) {
      if (lobby.game != null) continue;
      if (lobby.full) continue;
      if (lobby.gameType != GameType.Fortress) continue;
      return lobby;
    }

    return createLobbyFortress();
  }

  Lobby createLobbyDeathMatch() {
    return createLobby(
        maxPlayer: 2, gameType: GameType.DeathMatch, private: false);
  }

  Lobby createLobbyFortress() {
    return createLobby(
        maxPlayer: 4, gameType: GameType.Fortress, private: false);
  }

  Lobby createLobby({required int maxPlayer,
    required GameType gameType,
    String? name,
    required bool private}) {
    print(
        "create lobby(maxPlayers: $maxPlayer, type: $gameType, name: $name, private: $private)");
    Lobby lobby = Lobby(
        maxPlayers: maxPlayer,
        gameType: gameType,
        name: name,
        private: private);
    lobbies.add(lobby);
    return lobby;
  }

  DeathMatch createDeathMatch({int maxPlayer = 32}) {
    DeathMatch deathMatch = DeathMatch(maxPlayers: maxPlayer);
    compileAndAddGame(deathMatch);
    return deathMatch;
  }

  Fortress createGameFortress({required int maxPlayers}) {
    Fortress fortress = Fortress(maxPlayers: maxPlayers);
    compileAndAddGame(fortress);
    return fortress;
  }

  Fortress findOrCreateGameFortress({required int maxPlayers}) {
    Game? game = findAvailableGameByType(GameType.Fortress);
    if (game != null) return game as Fortress;
    return createGameFortress(maxPlayers: maxPlayers);
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
