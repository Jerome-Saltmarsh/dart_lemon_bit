import 'dart:async';

import 'package:bleed_server/user-service-client/firestoreService.dart';

import 'classes/Game.dart';
import 'classes/Player.dart';
import 'common/GameStatus.dart';
import 'common/Settings.dart';
import 'compile.dart';
import 'functions/loadScenes.dart';
import 'games/Moba.dart';
import 'games/Royal.dart';
import 'games/world.dart';
import 'language.dart';
import 'settings.dart';

const framesPerSecond = targetFPS;
const msPerFrame = Duration.millisecondsPerSecond ~/ framesPerSecond;
const msPerUpdateNpcTarget = 500;
const secondsPerRemoveDisconnectedPlayers = 4;
const secondsPerUpdateNpcObjective = 4;

final _Engine engine = _Engine();

class _Engine {
  // state
  final Map<String, Player> playerMap = {};
  final List<Game> games = [];
  int frame = 0;

  // config
  final framePerformStrike = 3;

  void init() {
    // @on init jobs
    Future.delayed(Duration(seconds: 3), () {
      periodic(fixedUpdate, ms: msPerFrame);
      periodic(updateNpcObjective, seconds: secondsPerUpdateNpcObjective);
      periodic(removeDisconnectedPlayers, seconds: secondsPerRemoveDisconnectedPlayers);
      periodic(updateNpcTargets, ms: msPerUpdateNpcTarget);
    });
  }

  void fixedUpdate(Timer timer) {
    worldTime = (worldTime + secondsPerFrame) % secondsPerDay;
    frame++;

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
          compile.game(game);
          break;

        case GameStatus.Finished:
          break;
      }
    }
  }

  void updateNpcTargets(Timer timer) {
    for (final game in games) {
      game.updateInteractableNpcTargets();
      game.updateZombieTargets();
    }
  }

  void removeDisconnectedPlayers(Timer timer) {
    for (Game game in games) {
      game.removeDisconnectedPlayers();
    }
  }

  void updateNpcObjective(Timer timer) {
    for (final game in games) {
      for (final zombie in game.zombies) {
        if (zombie.inactive) continue;
        if (zombie.busy) continue;
        if (zombie.dead) continue;
        final ai = zombie.ai;
        if (ai == null) continue;
        if (ai.target != null) continue;
        if (ai.path.isNotEmpty) continue;
        game.updateNpcObjective(ai);
        if (ai.objectives.isEmpty) {
          game.npcSetRandomDestination(ai);
        } else {
          final objective = ai.objectives.last;
          game.npcSetPathTo(ai, objective.x, objective.y);
        }
      }
    }
  }


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
    for (Game game in games) {
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
    for (Game game in games) {
      if (game is T == false) continue;
      if (!game.awaitingPlayers) continue;
      return game as T;
    }
    return null;
  }

  // This method is called by the game constructor automatically
  // and should not be called again
  void onGameCreated(Game game) {
    compile.game(game);
    game.compiledTiles = compileTiles(game.scene.tiles);
    game.compiledEnvironmentObjects =
        compileEnvironmentObjects(game.scene.environment);
    games.add(game);
  }

  void onPlayerCreated(Player player){
    player.game.players.add(player);
    registerPlayer(player);
  }

  Future<CustomGame> findOrCreateCustomGame(String mapId) async {
    for(Game game in games){
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


