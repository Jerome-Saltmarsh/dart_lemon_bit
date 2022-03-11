import 'dart:async';

import 'package:bleed_server/user-service-client/firestoreService.dart';

import 'classes/Game.dart';
import 'classes/Player.dart';
import 'classes/Scene.dart';
import 'common/GameStatus.dart';
import 'common/SlotType.dart';
import 'compile.dart';
import 'functions/loadScenes.dart';
import 'games/Moba.dart';
import 'games/Royal.dart';
import 'games/world.dart';
import 'language.dart';
import 'settings.dart';

const _targetFPS = 30;
const framesPerSecond = _targetFPS;
const _msPerFrame = Duration.millisecondsPerSecond ~/ framesPerSecond;
const _msPerUpdateNpcTarget = 500;
const _msPerRegen = 5000;
const _secondsPerRemoveDisconnectedPlayers = 4;

final engine = _Engine();

class _Engine {
  final Map<String, Player> playerMap = {};
  final List<Game> games = [];
  late final world;
  final scenes = _Scenes();
  int frame = 0;

  Future init() async {
    print("engine.init()");
    await scenes.load();
    world = World();
    Future.delayed(Duration(seconds: 3), () {
      periodic(fixedUpdate, ms: _msPerFrame);
      periodic(removeDisconnectedPlayers, seconds: _secondsPerRemoveDisconnectedPlayers);
      periodic(updateNpcTargets, ms: _msPerUpdateNpcTarget);
      periodic(regenCharacters, ms: _msPerRegen);
    });
    print("engine.init() finished");
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
          // compile.game(game);
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

  void regenCharacters(Timer timer){
    for (final game in games) {
      for(final player in game.players){
        player.health++;
        player.magic++;
      }
    }
  }

  void removeDisconnectedPlayers(Timer timer) {
    for (final game in games) {
      game.removeDisconnectedPlayers();
    }
  }

  // void updateZombieWander(Timer timer) {
  //   for (final game in games) {
  //     for (final zombie in game.zombies) {
  //       if (zombie.inactive) continue;
  //       if (zombie.busy) continue;
  //       if (zombie.dead) continue;
  //       final ai = zombie.ai;
  //       if (ai == null) continue;
  //       if (ai.target != null) continue;
  //       if (ai.mode != NpcMode.Aggressive) continue;
  //       game.npcSetRandomDestination(ai);
  //     }
  //   }
  // }


  Player? findPlayerByUuid(String uuid) {
    return playerMap[uuid];
  }

  void registerPlayer(Player player){
    playerMap[player.byteIdString] = player;
  }

  void deregisterPlayer(Player player){
    playerMap.remove(player.uuid);
  }

  GameMoba findPendingMobaGame() {
    for (final game in games) {
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
    for (final game in games) {
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
    for(final game in games){
      if (game is CustomGame == false) continue;
      final customGame = game as CustomGame;
      if (customGame.scene.name != mapId) continue;
      return customGame;
    }
    final customMapJson = await firestoreService.loadMap(mapId);
    final scene = parseJsonToScene(customMapJson, mapId);
    return CustomGame(scene);
  }

  Player spawnPlayerInTown() {
    return Player(
      game: world.town,
      x: 0,
      y: 1750,
      team: teams.west,
      health: 10,
      weapon: SlotType.Empty,
    );
  }

}

class _Scenes {
  late Scene town;
  late Scene tavern;
  late Scene wildernessWest01;
  late Scene wildernessNorth01;
  late Scene cave;
  late Scene wildernessEast;
  late Scene royal;

  Future load() async {
    print("loadScenes()");
    town = await loadSceneFromFile('town');
    tavern = await loadSceneFromFile('tavern');
    cave = await loadSceneFromFile('cave');
    wildernessWest01 = await loadSceneFromFile('wilderness-west-01');
    wildernessNorth01 = await loadSceneFromFile('wilderness-north-01');
    wildernessEast = await loadSceneFromFile('wilderness-east');
    royal = await loadSceneFromFireStore('royal');
  }
}