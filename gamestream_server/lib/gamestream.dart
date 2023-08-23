import 'dart:async';
import 'dart:io';

import 'firestore/firestore.dart';
import 'utils.dart';
import 'games.dart';
import 'common.dart';
import 'core.dart';
import 'isometric.dart';
import 'websocket/websocket_server.dart';

class GamestreamServer {

  static const Frames_Per_Second = 45;
  static const Fixed_Time = 50 / Frames_Per_Second;

  final games = <Game>[];
  final isometricScenes = Scenes();
  final database = isLocalMachine ? DatabaseLocalHost() : DatabaseFirestore();
  late final server = WebSocketServer(this);

  Timer? updateTimer;
  var frame = 0;

  GamestreamServer(){
    _construct();
  }


  Future _construct() async {
    printSystemInformation();
    await validate();
    await loadResources();
    initializeUpdateTimer();
    startServer();
  }

  void startServer() {
    server.start();
  }

  void initializeUpdateTimer() => updateTimer = Timer.periodic(
        Duration(milliseconds: 1000 ~/ Frames_Per_Second),
        _fixedUpdate,
    );

  void printSystemInformation() {
    print('gamestream-version: $version');
    print('dart-version: ${Platform.version}');
    if (isLocalMachine) {
      print("environment: Jerome's Computer");
    } else {
      print("environment: Google Cloud");
    }
  }

  Future loadResources() async {
    await isometricScenes.load();
  }

  Future validate() async {
    Amulet.validate();

    final sceneDirectoryExists = await isometricScenes.sceneDirectory.exists();

    if (!sceneDirectoryExists) {
      throw Exception('could not find scenes directory: ${isometricScenes
          .sceneDirectoryPath}');
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
      GameType.Amulet => buildGameMMO(),
      GameType.Capture_The_Flag => buildGameCaptureTheFlag(),
      GameType.Moba => buildGameMoba(),
      GameType.Editor => IsometricEditor(),
      _ => (throw Exception('gamestream.createNewGameByType(${gameType})'))
  };

  Game buildGameMMO() => Amulet(
      scene: isometricScenes.mmoTown,
      time: IsometricTime(enabled: true, hour: 14),
      environment: Environment(),
    );

  Game buildGameCaptureTheFlag() => CaptureTheFlagGame(
      scene: isometricScenes.captureTheFlag,
      time: IsometricTime(enabled: false, hour: 14),
      environment: Environment(),
    );

  Game buildGameMoba() => MobaGame(
      scene: isometricScenes.moba,
      time: IsometricTime(enabled: false, hour: 14),
      environment: Environment(),
    );

  Player joinGame(Game game) {
    final player = game.createPlayer();
    if (!game.players.contains(player)){
      game.players.add(player);
    }
    return player;
  }
}