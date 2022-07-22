

import 'package:lemon_math/library.dart';

import '../../classes/player.dart';
import '../../engine.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaTavernCellar extends DarkAgeAreaUnderground {
  AreaTavernCellar() : super(darkAgeScenes.tavernCellar) {

  }

  @override
  void checkPlayerPosition(Player player, int z, int row, int column) {
    if (z == 2 && row == 13 && column == 26) {
      changeGame(player, engine.findGameDarkAgeVillage());
      player.indexZ = 1;
      player.indexRow = 20;
      player.indexColumn = 14;
      player.x += giveOrTake(5);
    }
  }
}