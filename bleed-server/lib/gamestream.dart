import 'dart:async';
import 'dart:io';

import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/isometric/src.dart';
import 'package:bleed_server/firestore/firestore.dart';
import 'package:bleed_server/core/player.dart';
import 'package:bleed_server/websocket/websocket_server.dart';

import 'core/game.dart';
import 'games/src.dart';
import 'utils/system.dart';

class Gamestream {

  static const Frames_Per_Second = 45;

  final games = <Game>[];
  final isometricScenes = IsometricScenes();
  final database = isLocalMachine ? DatabaseLocalHost() : DatabaseFirestore();
  late final server = WebSocketServer(this);

  var _highScore = 0;
  var frame = 0;

  int get highScore => _highScore;

  set highScore(int value) {
    if (_highScore == value) return;
    _highScore = value;
    database.writeHighScore(_highScore);
    dispatchHighScore();
  }

  Future run() async {
    print('gamestream-version: $version');
    print('dart-version: ${Platform.version}');

    await database.connect();
    database.getHighScore().then((value) {
      highScore = value;
    });

    final sceneDirectoryExists = await isometricScenes.sceneDirectory.exists();

    if (!sceneDirectoryExists) {
      throw Exception('could not find scenes directory: ${isometricScenes
          .sceneDirectoryPath}');
    }

    if (isLocalMachine) {
      print("environment: Jerome's Computer");
    } else {
      print("environment: Google Cloud");
    }

    await isometricScenes.load();

    Timer.periodic(
        Duration(milliseconds: 1000 ~/ Frames_Per_Second), _fixedUpdate);
    server.start();
  }

  void dispatchHighScore() {
    for (final game in games) {
      for (final player in game.players) {
        if (player is IsometricPlayer) {
          player.writeHighScore();
        }
      }
    }
  }

  void _fixedUpdate(Timer timer) {
    frame++;

    if (frame % 100 == 0) {
      removeEmptyGames();
    }
    for (final game in games) {
      game.updateJobs();
      game.update();
      game.writePlayerResponses();
    }
    server.sendResponseToClients();
  }

  void removeEmptyGames() {
    for (var i = 0; i < games.length; i++) {
      if (games[i].players.isNotEmpty) continue;
      print("removing empty game ${games[i]}");
      games.removeAt(i);
      i--;
    }
  }

  Player joinGameByType(GameType gameType) => joinGame(findGameByGameType(gameType));

  Game findGameByGameType(GameType gameType){
    for (final game in games) {
      if (game.isFull) continue;
      if (game.gameType != gameType) continue;
      return game;
    }
    final newInstance = createNewGameByType(gameType);
    games.add(newInstance);
    return newInstance;
  }

  Game createNewGameByType(GameType gameType) => switch (gameType){
      GameType.Mmo => buildGameMMO(),
      GameType.Capture_The_Flag => buildGameCaptureTheFlag(),
      GameType.Moba => buildGameMoba(),
      GameType.Combat => buildGameCombat(),
      GameType.Fight2D => buildGameFight2D(),
      GameType.Rock_Paper_Scissors => RockPaperScissorsGame(),
      GameType.Editor => IsometricEditor(),
      _ => (throw Exception('gamestream.createNewGameByType(${gameType})'))
  };

  Game buildGameMMO() => MmoGame(
      scene: isometricScenes.mmoTown,
      time: IsometricTime(enabled: true, hour: 14),
      environment: IsometricEnvironment(),
    );

  Game buildGameCaptureTheFlag() => CaptureTheFlagGame(
      scene: isometricScenes.captureTheFlag,
      time: IsometricTime(enabled: false, hour: 14),
      environment: IsometricEnvironment(),
    );

  Game buildGameMoba() => Moba(
      scene: isometricScenes.moba,
      time: IsometricTime(enabled: false, hour: 14),
      environment: IsometricEnvironment(),
    );

  Game buildGameCombat() => CombatGame(scene: isometricScenes.warehouse02);

  Game buildGameFight2D() => GameFight2D(scene: GameFight2DSceneGenerator.generate());

  Player joinGame(Game game) {
    final player = game.createPlayer();
    if (!game.players.contains(player)){
      game.players.add(player);
    }
    player.writeGameType();
    return player;
  }
}