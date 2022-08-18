
import 'package:lemon_math/library.dart';

import '../../classes/library.dart';
import '../../engine.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeDarkFortress extends DarkAgeArea {
  GameDarkAgeDarkFortress() : super(darkAgeScenes.darkFortress, mapTile: -1);

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

      if (player.indexZ == 8 && column == 16 && (row == 18 || row == 18)) {
        player.changeGame(engine.findGameDarkAgeFortressDungeon());
        player.indexZ = 1;
        player.indexRow = 1;
        player.indexColumn = 27;
        player.y += giveOrTake(5);
        continue;
      }
    }
  }
}