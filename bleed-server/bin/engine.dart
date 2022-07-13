import 'dart:async';

import 'classes/library.dart';
import 'constants/frames_per_second.dart';
import 'dark_age/areas/game_dark_age_village.dart';
import 'dark_age/dark_age_scenes.dart';
import 'dark_age/dark_age_universe.dart';
import 'dark_age/game_dark_age.dart';
import 'dark_age/areas/game_dark_age_castle.dart';
import 'dark_age/game_dark_age_editor.dart';
import 'io/read_scene_from_file.dart';
import 'language.dart';

final engine = Engine();


class Engine {
  final games = <Game>[];
  var frame = 0;
  final officialUniverse = DarkAgeUniverse();

  Future init() async {
    await darkAgeScenes.load();
    periodic(fixedUpdate, ms: 1000 ~/ framesPerSecond);
  }

  void fixedUpdate(Timer timer) {
    officialUniverse.update();
    frame++;

    if (frame % 30 == 0) {
      for (final game in games) {
        game.updateAIPath();
      }
    }

    for (var i = 0; i < games.length; i++){
      games[i].updateStatus();
    }
  }

  Future<GameDarkAge> findGameEditorNew() async {
    return GameDarkAgeEditor();
  }

  Future<GameDarkAge> findGameEditorByName(String name) async {
    return GameDarkAgeEditor(scene: await readSceneFromFile(name));
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
    games.add(game);
  }

  void onPlayerCreated(Player player) {
    player.game.players.add(player);
    player.game.disableCountDown = 0;
  }

  GameDarkAgeCastle findGameDarkAgeCastle() {
    for (final game in games) {
      if (game is GameDarkAgeCastle) {
        if (game.full) continue;
        if (game.hasOwner) continue;
        return game;
      }
    }
    return GameDarkAgeCastle();
  }

  GameDarkAge findGameDarkAgeVillage() {
    for (final game in games) {
      if (game is GameDarkAgeVillage) {
        return game;
      }
    }
    return GameDarkAgeVillage();
  }
}
