import 'dart:async';
import 'dart:io';

import 'package:bleed_server/firestore/firestore.dart';
import 'package:bleed_server/src/websocket/websocket_server.dart';

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/games/game_editor.dart';
import 'package:bleed_server/src/io/save_directory.dart';
import 'package:bleed_server/src/scenes.dart';

import 'game/game.dart';
import 'games/isometric/isometric_player.dart';
import 'games/rock_paper_scissors/rock_paper_scissors_game.dart';
import 'system.dart';

final engine = Engine();

class Engine {

  static const Frames_Per_Second = 45;

  final games = <Game>[];
  final scenes = Scenes();
  final database = isLocalMachine ? DatabaseLocalHost() : DatabaseFirestore();
  final server = WebSocketServer();

  var _highScore = 0;
  var frame = 0;

  int get highScore => _highScore;

  set highScore (int value){
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

    final sceneDirectoryExists = await Scene_Directory.exists();

    if (!sceneDirectoryExists) {
      throw Exception('could not find scenes directory: $Scene_Directory_Path');
    }

    if (isLocalMachine) {
      print("environment: Jerome's Computer");
    } else{
      print("environment: Google Cloud");
    }

    await scenes.load();

    Timer.periodic(Duration(milliseconds: 1000 ~/ Frames_Per_Second), _fixedUpdate);
    server.start();
    // udpServer.start();
  }

  void dispatchHighScore(){
    for (final game in games) {
      for (final player in game.players){
        if (player is IsometricPlayer){
          player.writeHighScore();
        }
      }
    }
  }

  void _fixedUpdate(Timer timer) {
    frame++;
    for (final game in games){
      game.update();
      game.writePlayerResponses();
    }
    server.sendResponseToClients();
  }

  Future<GameEditor> findGameEditorNew() async {
    return GameEditor();
  }

  // This method is called by the game constructor automatically
  // and should not be called again
  void onGameCreated(Game game) {
    games.add(game);
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
}
