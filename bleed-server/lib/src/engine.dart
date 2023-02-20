import 'dart:async';
import 'dart:io';

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/dark_age/dark_age_scenes.dart';
import 'package:bleed_server/src/io/save_directory.dart';

import 'classes/src/game_time.dart';
import 'constants/frames_per_second.dart';
import 'dark_age/game_dark_age_editor.dart';
import 'network/websocket_server.dart';
import 'system.dart';

final engine = Engine();

class Engine {
  final games = <Game>[];
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

    if (!sceneDirectoryExists){
      throw Exception('could not find scenes directory: $Scene_Directory_Path');
    }

    if (isLocalMachine){
      print("Environment Detected: Jerome's Computer");
    }else{
      print("Environment Detected: Google Cloud Machine");
    }

    officialTime = GameTime();
    environmentAboveGround = GameEnvironment();
    environmentUnderground = GameEnvironment();
    await darkAgeScenes.load();

    // suburbs_01 = await loadScene('suburbs_01');

    // darkAgeScenes.saveAllToFile();

    // final mapRow1 = <DarkAgeArea>[
    //   AreaEmpty(),
    //   GameDarkAgeFarm(),
    //   AreaFarmB(),
    //   AreaMountainShrine(),
    //   AreaTown(),
    // ];
    // final mapRow2 = <DarkAgeArea>[
    //   AreaEmpty(),
    //   GameDarkAgeVillage(),
    //   AreaFarmA(),
    //   AreaLake(),
    //   Area_OldVillage(),
    //   Area_Cemetery_1(),
    //   AreaShrine1(),
    // ];
    // final mapRow3 = <DarkAgeArea>[
    //   AreaForestB(),
    //   GameDarkAgeForest(),
    //   AreaMountains1(),
    //   AreaMountains2(),
    //   AreaPlains2()
    // ];
    // final mapRow4 = <DarkAgeArea>[
    //   AreaForest3(),
    //   AreaForest4(),
    //   AreaMountains3(),
    //   AreaMountains4(),
    //   AreaPlains4(),
    // ];
    // gameMap.add(mapRow1);
    // gameMap.add(mapRow2);
    // gameMap.add(mapRow3);
    // gameMap.add(mapRow4);

    // for (var row = 0; row < gameMap.length; row++){
    //   final r = gameMap[row];
    //    for (var column = 0; column < r.length; column++){
    //       final area = gameMap[row][column];
    //       area.row = row;
    //       area.column = column;
    //    }
    // }

    Timer.periodic(Duration(milliseconds: 1000 ~/ framesPerSecond), fixedUpdate);
    startWebsocketServer();
  }

  // DarkAgeArea? getDarkArea(int row, int column){
  //    if (row < 0) return null;
  //    if (column < 0) return null;
  //    if (row >= gameMap.length) return null;
  //    if (column >= gameMap[0].length) return null;
  //    return gameMap[row][column];
  // }

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
