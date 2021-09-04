import '../enums/GameType.dart';
import '../utils.dart';
import 'Block.dart';
import 'Game.dart';
import 'Lobby.dart';
import 'Scene.dart';

class GameManager {
  List<Game> games = [];
  List<Lobby> lobbies = [];

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
    Scene scene = Scene(generateTiles(), blocks);
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

    Game deathMatch = DeathMatch();
    games.add(deathMatch);
    return deathMatch;
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
    return createLobby(maxPlayer: 8, gameType: GameType.DeathMatch, private: false);
  }

  Lobby createLobby({required int maxPlayer, required GameType gameType, String? name, required bool private}) {
    print("create lobby(maxPlayers: $maxPlayer, type: $gameType, name: $name, private: $private)");
    Lobby lobby = Lobby(maxPlayers: maxPlayer, gameType: gameType, name: name, private: private);
    lobbies.add(lobby);
    return lobby;
  }


  DeathMatch createDeathMatch({int maxPlayer = 32}) {
    DeathMatch deathMatch = DeathMatch(maxPlayers: maxPlayer);
    games.add(deathMatch);
    return deathMatch;
  }

  Fortress createGameFortress() {
    Fortress fortress = Fortress();
    games.add(fortress);
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
    Game deathMatch = DeathMatch();
    games.add(deathMatch);
    return deathMatch;
  }
}
