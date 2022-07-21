
import '../../classes/library.dart';
import '../../engine.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeDarkFortress extends DarkAgeArea {
  GameDarkAgeDarkFortress() : super(darkAgeScenes.darkFortress, mapX: 0, mapY: 0) {
    addEnemySpawn(z: 1, row: 14, column: 28, health: 5, max: 5, wanderRadius: 100);
    addEnemySpawn(z: 6, row: 15, column: 21, health: 5, max: 1, wanderRadius: 50);
    addEnemySpawn(z: 6, row: 24, column: 21, health: 5, max: 1, wanderRadius: 50);
  }

  @override
  void updateInternal() {
    for (var i = 0; i < players.length; i++) {
      final player = players[i];
      final row = player.indexRow;
      final column = player.indexColumn;

      if (column == 49 && (row == 6 || row == 7)) {
        player.changeGame(engine.findGameDarkAgeVillage());
        player.indexColumn = 1;
        continue;
      }

      if (column == 17 && (row == 19 || row == 18)) {
        player.changeGame(engine.findGameDarkAgeFortressDungeon());
        continue;
      }
    }
  }
}