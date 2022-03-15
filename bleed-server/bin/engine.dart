import 'dart:async';

import 'package:bleed_server/firestoreClient/firestoreService.dart';

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

final engine = _Engine();

class _Engine {
  // constants
  final framesPerSecond = 30;
  static const _msPerUpdateNpcTarget = 500;
  static const _msPerRegen = 5000;
  static const _secondsPerRemoveDisconnectedPlayers = 4;
  // immutables
  final Map<String, Player> playerMap = {};
  final List<Game> games = [];
  final scenes = _Scenes();
  late final world;
  // variables
  var frame = 0;

  Future init() async {
    print("engine.init()");
    await scenes.load();
    world = World();
    periodic(fixedUpdate, ms: Duration.millisecondsPerSecond ~/ framesPerSecond);
    // periodic(removeDisconnectedPlayers, seconds: _secondsPerRemoveDisconnectedPlayers);
    periodic(updateNpcTargets, ms: _msPerUpdateNpcTarget);
    periodic(regenCharacters, ms: _msPerRegen);
    print("engine.init() finished");
  }

  void fixedUpdate(Timer timer) {
    worldTime = (worldTime + secondsPerFrame) % secondsPerDay;
    frame++;

    for (final game in games) {

     game.removeDisconnectedPlayers();

      switch(game.status) {

        case GameStatus.In_Progress:
          game.updateInProgress();
          break;

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