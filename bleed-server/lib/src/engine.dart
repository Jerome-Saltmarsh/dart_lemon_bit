import 'dart:async';
import 'dart:io';

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/io/save_directory.dart';
import 'package:bleed_server/src/scenes.dart';

import 'classes/src/game_time.dart';
import 'constants/frames_per_second.dart';
import 'dark_age/game_dark_age_editor.dart';
import 'network/websocket_server.dart';
import 'system.dart';

final engine = Engine();

class Engine {
  final games = <Game>[];
  final scenes = Scenes();
  var frame = 0;
  late GameTime officialTime;
  late GameEnvironment environmentAboveGround;
  late GameEnvironment environmentUnderground;

  Future run() async {
    print('gamestream-version: $version');

    print('dart-version: ${Platform.version}');
    print('gamestream.online server starting');
    // print("Directory.current.path: ${Directory.current.path}");

    final sceneDirectoryExists = await Scene_Directory.exists();

    if (!sceneDirectoryExists) {
      throw Exception('could not find scenes directory: $Scene_Directory_Path');
    }

    if (isLocalMachine) {
      print("Environment Detected: Jerome's Computer");
    } else{
      print("Environment Detected: Google Cloud Machine");
    }

    officialTime = GameTime();
    environmentAboveGround = GameEnvironment();
    environmentUnderground = GameEnvironment();
    await scenes.load();

    Timer.periodic(Duration(milliseconds: 1000 ~/ framesPerSecond), fixedUpdate);
    startWebsocketServer();
  }

  void fixedUpdate(Timer timer) {
    environmentAboveGround.update();
    officialTime.update();
    frame++;

    for (var i = 0; i < games.length; i++){
      games[i].updateStatus();
    }
  }

  Future<GameDarkAgeEditor> findGameEditorNew() async {
    return GameDarkAgeEditor();
  }

  // This method is called by the game constructor automatically
  // and should not be called again
  void onGameCreated(Game game) {
    games.add(game);
  }
}
