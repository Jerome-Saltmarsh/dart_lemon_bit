
import '../engine.dart';
import 'game_dark_age.dart';
import 'dark_age_scenes.dart';

class GameDarkAgeCastle extends GameDarkAge {
  GameDarkAgeCastle() : super(darkAgeScenes.castle);

  @override
  void updateInternal(){
    var playerLength = players.length;
    for (var i = 0; i < playerLength; i++) {
      final player = players[i];
      if (player.indexRow != 27) continue;
      if (player.indexColumn != 0) continue;
      player.changeGame(engine.findGameDarkAgeVillage());
      player.x = 1150;
      player.y = 910;
      i--;
      playerLength--;
    }
  }
}