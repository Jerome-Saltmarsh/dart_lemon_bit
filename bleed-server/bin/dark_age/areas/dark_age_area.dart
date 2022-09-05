
import '../../classes/library.dart';
import '../../common/library.dart';
import '../../engine.dart';
import '../game_dark_age.dart';


class DarkAgeArea extends GameDarkAge {
  var row = 0;
  var column = 0;
  var mapTile = 0;

  DarkAgeArea(Scene scene, {required this.mapTile})
      : super(scene, engine.environmentAboveGround);

  void update() {
    super.update();
    updateCheckPlayerChangeMap();
  }

  void updateCheckPlayerChangeMap(){
    for (var i = 0; i < players.length; i++){
      final player = players[i];
      if (player.y <= tileSizeHalf){
        if (column <= 0) continue;
        player.changeGame(engine.map[row][column - 1]);
        player.indexColumn = player.scene.gridColumns - 2;
        continue;
      }
      if (player.x <= tileSizeHalf){
        if (row <= 0) continue;
        player.changeGame(engine.map[row - 1][column]);
        player.indexRow = player.scene.gridRows - 2;
        continue;
      }
      if (player.x >= scene.gridRowLength - tileSizeHalf){
        if (row >= engine.map.length - 1) continue;
        player.changeGame(engine.map[row + 1][column]);
        player.indexRow = 1;
        continue;
      }
      if (player.y >= scene.gridColumnLength - tileSizeHalf){
        if (column >= engine.map[row].length - 1) continue;
        player.changeGame(engine.map[row][column + 1]);
        player.indexColumn = 1;
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