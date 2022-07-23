
import '../../classes/player.dart';
import '../../common/map_tiles.dart';
import '../../engine.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeFortressDungeon extends DarkAgeAreaUnderground {
  GameDarkAgeFortressDungeon() : super(darkAgeScenes.darkFortressDungeon, mapTile: MapTiles.Dark_Castle) {

  }

  @override
  void checkPlayerPosition(Player player, int z, int row, int column) {
    if (z == 2 && row == 0 && (column == 27 || column == 26)) {
      changeGame(player, engine.findGameDarkDarkFortress());
    }
  }
}