
import '../../classes/library.dart';
import '../../engine.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeFarm extends DarkAgeArea {
  GameDarkAgeFarm() : super(darkAgeScenes.farm, mapX: 1, mapY: 0) {
      addEnemySpawn(z: 1, row: 34, column: 30, health: 5, max: 5, wanderRadius: 300);
  }


  @override
  void updateInternal() {
    for (var i = 0; i < players.length; i++) {
      final player = players[i];
      final row = player.indexRow;
      final column = player.indexColumn;

      if (row == 49 && (column == 9 || column == 8)) {
        player.changeGame(engine.findGameDarkAgeVillage());
        player.indexRow = 1;
        continue;
      }
    }
  }
}