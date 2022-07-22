import 'dart:async';

import 'classes/library.dart';
import 'constants/frames_per_second.dart';
import 'dark_age/areas/game_dark_age_dark_fortress.dart';
import 'dark_age/areas/game_dark_age_farm.dart';
import 'dark_age/areas/game_dark_age_forest.dart';
import 'dark_age/areas/game_dark_age_fortress_dungeon.dart';
import 'dark_age/areas/game_dark_age_village.dart';
import 'dark_age/dark_age_scenes.dart';
import 'dark_age/dark_age_universe.dart';
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
  late DarkAgeUniverse environmentAboveGround;
  late DarkAgeUniverse environmentUnderground;

  Future init() async {
    officialTime = DarkAgeTime();
    environmentAboveGround = DarkAgeUniverse(officialTime);
    environmentUnderground = DarkAgeUniverse(officialTime);

    await darkAgeScenes.load();
    periodic(fixedUpdate, ms: 1000 ~/ framesPerSecond);
  }

  void fixedUpdate(Timer timer) {
    environmentAboveGround.update();
    officialTime.update();
    frame++;

    removeEmptyGames();
    // updateAIPathfinding();

    for (var i = 0; i < games.length; i++){
      games[i].updateStatus();
    }
  }

  void removeEmptyGames() {
    if (frame % 1000 != 0) return;
    for (var i = 0; i < games.length; i++) {
      if (games[i].players.isNotEmpty) continue;
      games.removeAt(i);
      i--;
    }
  }

  void updateAIPathfinding() {
    if (frame % 30 != 0) return;
    for (final game in games) {
      game.updateAIPath();
    }
  }

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
