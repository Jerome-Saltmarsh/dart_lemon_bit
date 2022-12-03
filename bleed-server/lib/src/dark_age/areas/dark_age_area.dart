
import 'package:bleed_server/gamestream.dart';
import '../game_dark_age.dart';

abstract class DarkAgeArea extends GameDarkAge {
  var row = 0;
  var column = 0;
  var mapTile = 0;

  int get areaType;

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
        changeGame(player, engine.gameMap[row][column - 1]);
        Game.setPositionColumn(player, player.scene.gridColumns - 1);
        continue;
      }
      if (player.x <= radius){
        if (row <= 0) continue;
        changeGame(player, engine.gameMap[row - 1][column]);
        Game.setPositionRow(player, player.scene.gridRows - 1);
        continue;
      }
      if (player.x >= scene.gridRowLength - radius){
        if (row >= engine.gameMap.length - 1) continue;
        changeGame(player, engine.gameMap[row + 1][column]);
        Game.setPositionRow(player, 0);
        continue;
      }
      if (player.y >= scene.gridColumnLength - radius){
        if (column >= engine.gameMap[row].length - 1) continue;
        changeGame(player, engine.gameMap[row][column + 1]);
        Game.setPositionColumn(player, 0);
        continue;
      }
    }
  }

  @override
  void customDownloadScene(Player player){
      player.writeByte(ServerResponse.Dark_Age);
      player.writeByte(ApiDarkAge.areaType);
      player.writeByte(areaType);
  }
}

// class DarkAgeAreaUnderground extends GameDarkAge {
//
//   @override
//   bool get customPropMapVisible => false;
//
//   var mapTile = 0;
//   DarkAgeAreaUnderground(Scene scene, {required this.mapTile})
//       : super(scene, engine.environmentUnderground);
// }