import 'package:bleed_server/user-service-client/firestoreService.dart';

import 'classes/Game.dart';
import 'classes/Player.dart';
import 'common/GameStatus.dart';
import 'compile.dart';
import 'functions/loadScenes.dart';
import 'games/Moba.dart';
import 'games/Royal.dart';
import 'settings.dart';

final _Global global = _Global();

class _Global {
  final Map<String, Player> playerMap = {};
  final List<Game> games = [];

  Player? findPlayerByUuid(String uuid) {
    return playerMap[uuid];
  }

  void registerPlayer(Player player){
    playerMap[player.uuid] = player;
  }

  void deregisterPlayer(Player player){
    playerMap.remove(player.uuid);
  }

  GameMoba findPendingMobaGame() {
    for (Game game in global.games) {
      if (game is GameMoba) {
        if (game.awaitingPlayers) {
          return game;
        }
      }
    }
    return GameMoba();
  }

  GameRoyal findPendingRoyalGames() {
    return findGameAwaitingPlayers<GameRoyal>() ?? GameRoyal();
  }

  T? findGameAwaitingPlayers<T extends Game>() {
    for (Game game in global.games) {
      if (game is T == false) continue;
      if (!game.awaitingPlayers) continue;
      return game as T;
    }
    return null;
  }

  // This method is called by the game constructor automatically
  // and should not be called again
  void onGameCreated(Game game) {
    compileGame(game);
    game.compiledTiles = compileTiles(game.scene.tiles);
    game.compiledEnvironmentObjects =
        compileEnvironmentObjects(game.scene.environment);
    games.add(game);
  }

  void onPlayerCreated(Player player){
    player.game.players.add(player);
    registerPlayer(player);
  }

  void update() {
    for (final game in games) {
      switch(game.status) {
        case GameStatus.Awaiting_Players:
          for (int i = 0; i < game.players.length; i++) {
            final player = game.players[i];
            player.lastUpdateFrame++;
            if (player.lastUpdateFrame > settings.framesUntilPlayerDisconnected) {
              game.players.removeAt(i);
              deregisterPlayer(player);
              i--;
            }
          }
          break;

        case GameStatus.Counting_Down:
          game.countDownFramesRemaining--;
          if (game.countDownFramesRemaining <= 0) {
            game.status = GameStatus.In_Progress;
            game.onGameStarted();
          }
          break;

        case GameStatus.In_Progress:
          game.updateInProgress();
          break;

        case GameStatus.Finished:
          break;
      }
    }
  }

  Future<CustomGame> findOrCreateCustomGame(String mapId) async {
    for(Game game in global.games){
      if (game is CustomGame == false) continue;
      final customGame = game as CustomGame;
      if (customGame.scene.name != mapId) continue;
      return customGame;
    }
    final customMapJson = await firestoreService.loadMap(mapId);
    final scene = parseJsonToScene(customMapJson, mapId);
    return CustomGame(scene);
  }
}
