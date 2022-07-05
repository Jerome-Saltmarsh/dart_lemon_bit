
import '../engine.dart';
import 'game_dark_age.dart';
import 'dark_age_scenes.dart';

class GameDarkAgeCastle extends GameDarkAge {
  GameDarkAgeCastle() : super(darkAgeScenes.castle);

  @override
  void updateInternal(){
    for (var i = 0; i < players.length; i++) {
      final player = players[i];
      if (player.indexRow != 27) continue;
      if (player.indexColumn != 0) continue;
      player.changeGame(engine.findGameDarkAgeVillage());
      player.x = 960;
      player.y = 2320;
    }
  }
}