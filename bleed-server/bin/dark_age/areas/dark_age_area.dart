
import '../../classes/library.dart';
import '../../engine.dart';
import '../game_dark_age.dart';


class DarkAgeArea extends GameDarkAge {
  var row = 0;
  var column = 0;
  var mapTile = 0;

  DarkAgeArea(Scene scene, {required this.mapTile})
      : super(scene, engine.environmentAboveGround);

  void customUpdate() {
    super.customUpdate();
    updateCheckPlayerChangeMap();
  }

  void updateCheckPlayerChangeMap(){
    const radius = 12;
    for (var i = 0; i < players.length; i++){
      final player = players[i];
      if (player.y <= radius){
        if (column <= 0) continue;
        player.changeGame(engine.map[row][column - 1]);
        player.indexColumn = player.scene.gridColumns - 1;
        continue;
      }
      if (player.x <= radius){
        if (row <= 0) continue;
        player.changeGame(engine.map[row - 1][column]);
        player.indexRow = player.scene.gridRows - 1;
        continue;
      }
      if (player.x >= scene.gridRowLength - radius){
        if (row >= engine.map.length - 1) continue;
        player.changeGame(engine.map[row + 1][column]);
        player.indexRow = 0;
        continue;
      }
      if (player.y >= scene.gridColumnLength - radius){
        if (column >= engine.map[row].length - 1) continue;
        player.changeGame(engine.map[row][column + 1]);
        player.indexColumn = 0;
        continue;
      }
    }
  }
}

class DarkAgeAreaUnderground extends GameDarkAge {
  var mapTile = 0;
  DarkAgeAreaUnderground(Scene scene, {required this.mapTile})
      : super(scene, engine.environmentUnderground);
}