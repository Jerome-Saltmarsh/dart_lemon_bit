
import '../../classes/library.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeDarkFortress extends DarkAgeArea {
  GameDarkAgeDarkFortress() : super(darkAgeScenes.darkFortress, mapX: 0, mapY: 0) {
    addEnemySpawn(z: 1, row: 14, column: 28, health: 5, max: 5, wanderRadius: 100);
  }
}