import 'dart:async';

import 'package:bleed_server/firestoreClient/firestoreService.dart';

import 'classes/library.dart';
import 'common/library.dart';
import 'functions/loadScenes.dart';
import 'games/GameRandom.dart';
import 'games/GameSwarm.dart';
import 'games/Moba.dart';
import 'games/Royal.dart';
import 'games/Skirmish.dart';
import 'games/game_night_survivors.dart';
import 'language.dart';

final engine = _Engine();

class _Engine {
  static const framesPerSecond = 45;
  static const framesPerRegen = 30 * 10;
  static const framesPerUpdateAIPath = 30;
  final games = <Game>[];
  final scenes = _Scenes();
  late final world;
  var frame = 0;

  Future init() async {
    periodic(fixedUpdate, ms: 1000 ~/ framesPerSecond);
  }

  void fixedUpdate(Timer timer) {
    frame++;

    if (frame % 5 == 0) {
      games.removeWhere((game) => game.finished);

      for (var i = 0; i < games.length; i++) {
        final game = games[i];
        if (game.disableCountDown < 15) continue;
        assert(game.players.isEmpty);
        games.removeAt(i);
        i--;
      }

    }

    if (frame % framesPerRegen == 0) {
      regenCharacters();
    }
    if (frame % framesPerUpdateAIPath == 0) {
      _updateAIPaths();
    }

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
            if (player.lastUpdateFrame > 100) {
              game.players.removeAt(i);
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

        default:
          break;
      }
    }

    for (final game in games) {
      final players = game.players;
      for (final player in players) {
        player.writePlayerGame();
        player.writeByte(ServerResponse.End);
        player.sendBufferToClient();
      }
    }
  }

  void _updateAIPaths() {
    for (final game in games) {
      final zombies = game.zombies;
      for (final zombie in zombies) {
          if (zombie.deadOrBusy) continue;
          final target = zombie.target;
          if (target == null) continue;
          game.npcSetPathTo(zombie, target);
      }
    }
  }

  void regenCharacters(){
    for (final game in games) {
      final players = game.players;
      for (final player in players) {
        if (player.dead) continue;
        player.health++;
        player.magic++;
      }
    }
  }

  GameSkirmish findGameSkirmish() {
    for (final game in games) {
      if (game is GameSkirmish) {
        return game;
      }
    }
    return GameSkirmish();
  }

  GameSwarm findGameSwarm() {
    return GameSwarm();
  }

  GameRandom findRandomGame() {
    for (final game in games) {
      if (game is GameRandom) {
        if (game.full) continue;
        if (game.empty) continue;
        return game;
      }
    }
    return GameRandom(maxPlayers: 12);
  }

  GameNightSurvivors findGameAfterDark() {
    for (final game in games) {
      if (game is GameNightSurvivors && !game.isFull) {
        return game;
      }
    }
    return GameNightSurvivors();
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
    // compile.game(game);
    // game.compiledTiles = compileTiles(game.scene.tiles);
    // game.compiledEnvironmentObjects =
    //     compileEnvironmentObjects(game.scene.environment);
    games.add(game);
  }

  void onPlayerCreated(Player player) {
    player.game.players.add(player);
    player.game.disableCountDown = 0;
  }

  Future<CustomGame> findOrCreateCustomGame(String mapId) async {
    for(final game in games){
      if (game is CustomGame == false) continue;
      final customGame = game as CustomGame;
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
      team: Teams.west,
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
  late Scene skirmish;

  Future load() async {
    print("loadScenes()");
    town = await loadSceneFromFile('town');
    tavern = await loadSceneFromFile('tavern');
    cave = await loadSceneFromFile('cave');
    wildernessWest01 = await loadSceneFromFile('wilderness-west-01');
    wildernessNorth01 = await loadSceneFromFile('wilderness-north-01');
    wildernessEast = await loadSceneFromFile('wilderness-east');
    // royal = await loadSceneFromFireStore('royal');
    skirmish = await loadSceneFromFireStore('skirmish');
  }
}