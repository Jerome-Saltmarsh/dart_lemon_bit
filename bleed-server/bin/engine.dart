import 'dart:async';

import 'classes/library.dart';
import 'common/library.dart';
import 'constants/frames_per_second.dart';
import 'dark_age/areas/area-empty.dart';
import 'dark_age/areas/area-farm-a.dart';
import 'dark_age/areas/area-farm-b.dart';
import 'dark_age/areas/area-forest-b.dart';
import 'dark_age/areas/area-mountain-shrine.dart';
import 'dark_age/areas/area-plains-1.dart';
import 'dark_age/areas/area-town.dart';
import 'dark_age/areas/area_lake.dart';
import 'dark_age/areas/area_tavern_cellar.dart';
import 'dark_age/areas/dark_age_area.dart';
import 'dark_age/areas/game_dark_age_dark_fortress.dart';
import 'dark_age/areas/game_dark_age_farm.dart';
import 'dark_age/areas/game_dark_age_forest.dart';
import 'dark_age/areas/game_dark_age_fortress_dungeon.dart';
import 'dark_age/areas/game_dark_age_village.dart';
import 'dark_age/dark_age_scenes.dart';
import 'dark_age/dark_age_environment.dart';
import 'dark_age/game_dark_age.dart';
import 'dark_age/areas/game_dark_age_college.dart';
import 'dark_age/game_dark_age_editor.dart';
import 'io/read_scene_from_file.dart';
import 'language.dart';

final engine = Engine();

class Engine {
  final games = <Game>[];
  var frame = 0;
  late DarkAgeTime officialTime;
  late DarkAgeEnvironment environmentAboveGround;
  late DarkAgeEnvironment environmentUnderground;

  final map = <List<DarkAgeArea>>[];

  Future init() async {
    officialTime = DarkAgeTime();
    environmentAboveGround = DarkAgeEnvironment(officialTime);
    environmentUnderground = DarkAgeEnvironment(officialTime, maxShade: Shade.Pitch_Black);
    await darkAgeScenes.load();

    final mapRow1 = <DarkAgeArea>[
      AreaEmpty(),
      GameDarkAgeFarm(),
      AreaFarmB(),
      AreaMountainShrine(),
      AreaTown(),
    ];
    final mapRow2 = <DarkAgeArea>[
      AreaEmpty(),
      GameDarkAgeVillage(),
      AreaFarmA(),
      AreaLake(),
      AreaPlains1(),
    ];
    final mapRow3 = <DarkAgeArea>[
      AreaForestB(),
      GameDarkAgeForest(),
    ];
    map.add(mapRow1);
    map.add(mapRow2);
    map.add(mapRow3);

    for (var row = 0; row < map.length; row++){
      final r = map[row];
       for (var column = 0; column < r.length; column++){
          final area = map[row][column];
          area.row = row;
          area.column = column;
       }
    }

    periodic(fixedUpdate, ms: 1000 ~/ framesPerSecond);
  }

  void fixedUpdate(Timer timer) {
    environmentAboveGround.update();
    officialTime.update();
    frame++;

    // removeEmptyGames();
    // updateAIPathfinding();

    for (var i = 0; i < games.length; i++){
      games[i].updateStatus();
    }
  }

  // void removeEmptyGames() {
  //   if (frame % 1000 != 0) return;
  //   for (var i = 0; i < games.length; i++) {
  //     if (games[i].players.isNotEmpty) continue;
  //     games.removeAt(i);
  //     i--;
  //   }
  // }

  Future<GameDarkAge> findGameEditorNew() async {
    return GameDarkAgeEditor();
  }

  Future<GameDarkAge> findGameEditorByName(String name) async {
    return GameDarkAgeEditor(scene: await readSceneFromFile(name));
  }

  // This method is called by the game constructor automatically
  // and should not be called again
  void onGameCreated(Game game) {
    games.add(game);
  }

  GameDarkAgeCollege findGameDarkAgeCastle() {
    for (final game in games) {
      if (game is GameDarkAgeCollege) {
        return game;
      }
    }
    return GameDarkAgeCollege();
  }

  GameDarkAge findGameDarkAgeVillage() {
    for (final game in games) {
      if (game is GameDarkAgeVillage) {
        return game;
      }
    }
    return GameDarkAgeVillage();
  }

  GameDarkAge findAreaTavernCellar() {
    for (final game in games) {
      if (game is AreaTavernCellar) {
        return game;
      }
    }
    return AreaTavernCellar();
  }

  GameDarkAge findGameDarkAgeFortressDungeon() {
    for (final game in games) {
      if (game is GameDarkAgeFortressDungeon) {
        return game;
      }
    }
    return GameDarkAgeFortressDungeon();
  }

  GameDarkAge findGameDarkDarkFortress() {
    for (final game in games) {
      if (game is GameDarkAgeDarkFortress) {
        return game;
      }
    }
    return GameDarkAgeDarkFortress();
  }

  GameDarkAgeForest findGameForest() {
    for (final game in games) {
      if (game is GameDarkAgeForest) {
        return game;
      }
    }
    return GameDarkAgeForest();
  }

  GameDarkAgeFarm findGameFarm() {
    for (final game in games) {
      if (game is GameDarkAgeFarm) {
        return game;
      }
    }
    return GameDarkAgeFarm();
  }
}
