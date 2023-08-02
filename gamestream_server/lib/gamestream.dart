import 'dart:async';
import 'dart:io';

import 'firestore/firestore.dart';
import 'utils.dart';
import 'games.dart';
import 'common.dart';
import 'core.dart';
import 'isometric.dart';
import 'websocket/websocket_server.dart';

class Gamestream {

  static const Frames_Per_Second = 45;
  static const Fixed_Time = 50 / Frames_Per_Second;

  final games = <Game>[];
  final isometricScenes = IsometricScenes();
  final database = isLocalMachine ? DatabaseLocalHost() : DatabaseFirestore();
  late final server = WebSocketServer(this);

  var frame = 0;


  Future run() async {
    print('gamestream-version: $version');
    print('dart-version: ${Platform.version}');

    Amulet.validate();

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
      GameType.Amulet => buildGameMMO(),
      GameType.Capture_The_Flag => buildGameCaptureTheFlag(),
      GameType.Moba => buildGameMoba(),
      GameType.Editor => IsometricEditor(),
      _ => (throw Exception('gamestream.createNewGameByType(${gameType})'))
  };

  Game buildGameMMO() => Amulet(
      scene: isometricScenes.mmoTown,
      time: IsometricTime(enabled: true, hour: 14),
      environment: IsometricEnvironment(),
    );

  Game buildGameCaptureTheFlag() => CaptureTheFlagGame(
      scene: isometricScenes.captureTheFlag,
      time: IsometricTime(enabled: false, hour: 14),
      environment: IsometricEnvironment(),
    );

  Game buildGameMoba() => MobaGame(
      scene: isometricScenes.moba,
      time: IsometricTime(enabled: false, hour: 14),
      environment: IsometricEnvironment(),
    );

  Player joinGame(Game game) {
    final player = game.createPlayer();
    if (!game.players.contains(player)){
      game.players.add(player);
    }
    // player.writeGameType();
    // player.writeFPS();
    return player;
  }
}