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
    Scene scene = Scene(tiles: generateTiles(), blocks: blocks, crates: []);
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
      if (game.type != type) continue;
      if (game.players.length >= game.maxPlayers) continue;
      return game;
    }
    return null;
  }

  Lobby findAvailableDeathMatchLobby(
      {required int squadSize, required int maxPlayers}) {
    if (lobbies.isEmpty)
      return createLobbyDeathMatch(
          squadSize: squadSize, maxPlayers: maxPlayers);

    for (Lobby lobby in lobbies) {
      if (lobby.game != null) continue;
      if (lobby.full) continue;
      if (lobby.gameType != GameType.DeathMatch) continue;
      return lobby;
    }

    return createLobbyDeathMatch(squadSize: squadSize, maxPlayers: maxPlayers);
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

  Lobby createLobbyDeathMatch(
      {required int maxPlayers, required int squadSize}) {
    return createLobby(
        maxPlayers: maxPlayers,
        gameType: GameType.DeathMatch,
        private: false,
        squadSize: squadSize);
  }

  Lobby createLobbyFortress() {
    return createLobby(
        maxPlayers: 4,
        gameType: GameType.Fortress,
        private: false,
        squadSize: 4);
  }

  Lobby createLobby(
      {required int maxPlayers,
      required GameType gameType,
      String? name,
      required bool private,
      required int squadSize}) {
    print(
        "createLobby(maxPlayers: $maxPlayers, gameType: $gameType, name: $name, private: $private, squadSize: $squadSize)");
    Lobby lobby = Lobby(
        maxPlayers: maxPlayers,
        gameType: gameType,
        name: name,
        private: private,
        squadSize: squadSize);
    lobbies.add(lobby);
    return lobby;
  }

  DeathMatch createDeathMatch(
      {required int maxPlayer, required int squadSize}) {
    print("createDeathMatch(maxPlayer: $maxPlayer, squadSize: $squadSize)");
    DeathMatch deathMatch =
        DeathMatch(maxPlayers: maxPlayer, squadSize: squadSize);
    compileAndAddGame(deathMatch);
    return deathMatch;
  }

  Fortress createGameFortress({required int maxPlayers}) {
    print("createGameFortress(maxPlayer: $maxPlayers)");
    Fortress fortress = Fortress(maxPlayers: maxPlayers);
    compileAndAddGame(fortress);
    return fortress;
  }

  Fortress findOrCreateGameFortress({required int maxPlayers}) {
    Game? game = findAvailableGameByType(GameType.Fortress);
    if (game != null) return game as Fortress;
    return createGameFortress(maxPlayers: maxPlayers);
  }
}
