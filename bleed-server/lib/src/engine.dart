import 'dart:async';
import 'dart:io';

import 'package:bleed_server/common/src/version.dart';
import 'package:bleed_server/firestore/firestore.dart';
import 'package:bleed_server/src/game/player.dart';
import 'package:bleed_server/src/websocket/websocket_server.dart';

import 'package:bleed_server/src/games/game_editor.dart';
import 'package:bleed_server/src/games/isometric/isometric_scenes.dart';

import 'game/game.dart';
import 'games/capture_the_flag/capture_the_flag_game.dart';
import 'games/fight2d/game_fight2d.dart';
import 'games/fight2d/game_fight2d_scene_generator.dart';
import 'games/combat/game_combat.dart';
import 'games/isometric/isometric_environment.dart';
import 'games/isometric/isometric_player.dart';
import 'games/isometric/isometric_time.dart';
import 'games/rock_paper_scissors/rock_paper_scissors_game.dart';
import 'utilities/system.dart';

class Engine {

  static const Frames_Per_Second = 45;

  final games = <Game>[];
  final isometricScenes = IsometricScenes();
  final database = isLocalMachine ? DatabaseLocalHost() : DatabaseFirestore();
  late final server = WebSocketServer(this);

  var _highScore = 0;
  var frame = 0;


  Engine() {
    run();
  }

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

  RockPaperScissorsGame getGameRockPaperScissors() {
    for (final game in games) {
      if (game is RockPaperScissorsGame) {
        return game;
      }
    }
    final gameInstance = RockPaperScissorsGame();
    games.add(gameInstance);
    return gameInstance;
  }

  Player joinGameCaptureTheFlag() {
    for (final game in games) {
      if (game.isFull) continue;
      if (game is! CaptureTheFlagGame) continue;
      return joinGame(game);
    }

    return joinGame(CaptureTheFlagGame(
      scene: isometricScenes.captureTheFlag,
      time: IsometricTime(enabled: false, hour: 14),
      environment: IsometricEnvironment(),
    )
    );
  }


  Player joinGameEditor({String? name}) {
    return joinGame(GameEditor());
  }


  Player joinGameFight2D() {
    for (final game in games) {
      if (game.isFull) continue;
      if (game is! GameFight2D) continue;
      return joinGame(game);
    }
    return joinGame(GameFight2D(scene: GameFight2DSceneGenerator.generate()));
  }

  Player joinGame(Game game) {
    if (!games.contains(game)) {
      games.add(game);
    }
    final player = game.createPlayer();
    if (!game.players.contains(player)){
      game.players.add(player);
    }
    player.writeGameType();
    return player;
  }

  Player joinGameCombat() {
    for (final game in games) {
      if (game.isFull) continue;
      if (game is! GameCombat) continue;
      return joinGame(game);
    }
    return joinGame(GameCombat(scene: isometricScenes.warehouse02));
  }
}