
import '../../classes/library.dart';
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

     for (var i = 0; i < players.length; i++){
       final player = players[i];
       if (player.indexColumn == 0){
           if (column <= 0) continue;
           player.changeGame(engine.map[row][column - 1]);
           player.indexColumn = 48;
           continue;
       }
       if (player.indexRow == 0){
         if (row <= 0) continue;
         player.changeGame(engine.map[row - 1][column]);
         player.indexRow = 48;
         continue;
       }
       if (player.indexRow == scene.gridRows - 1){
         if (row >= engine.map.length - 1) continue;
         player.changeGame(engine.map[row + 1][column]);
         player.indexRow = 1;
         continue;
       }
       if (player.indexColumn == scene.gridColumns - 1){
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