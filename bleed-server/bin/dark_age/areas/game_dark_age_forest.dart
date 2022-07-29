
import '../../classes/library.dart';
import '../../common/map_tiles.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeForest extends DarkAgeArea {
  GameDarkAgeForest() : super(darkAgeScenes.forest, mapTile: MapTiles.Forest) {
    addEnemySpawn(z: 1, row: 8, column: 16, health: 5, max: 3);
  }
}