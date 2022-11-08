
import 'package:lemon_math/functions/give_or_take.dart';

import '../../classes/library.dart';
import '../../common/library.dart';
import '../../engine.dart';
import '../game_dark_age.dart';

class DarkAgeArea extends GameDarkAge {
  var row = 0;
  var column = 0;
  var mapTile = 0;

  DarkAgeArea(Scene scene, {required this.mapTile})
      : super(scene, engine.environmentAboveGround) {
    final volume = scene.gridVolume;

    for (var i = 0; i < volume; i++) {
      if (scene.nodeTypes[i] == NodeType.Spawn) {
        for (var j = 0; j < 4; j++){
          final instance = spawnZombieAtIndex(i);
          instance.x += giveOrTake(50);
          instance.y += giveOrTake(50);
          instance.clearDest();
          instance.maxHealth = 10;
          instance.health = 10;
          instance.respawn = 500;
          instance.maxSpeed = 3;
          instance.spawnX = instance.x;
          instance.spawnY = instance.y;
          instance.spawnZ = instance.z;
          continue;
        }
      }
    }
  }

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
        player.indexColumn = player.scene.gridColumns - 1;
        continue;
      }
      if (player.x <= radius){
        if (row <= 0) continue;
        changeGame(player, engine.gameMap[row - 1][column]);
        player.indexRow = player.scene.gridRows - 1;
        continue;
      }
      if (player.x >= scene.gridRowLength - radius){
        if (row >= engine.gameMap.length - 1) continue;
        changeGame(player, engine.gameMap[row + 1][column]);
        player.indexRow = 0;
        continue;
      }
      if (player.y >= scene.gridColumnLength - radius){
        if (column >= engine.gameMap[row].length - 1) continue;
        changeGame(player, engine.gameMap[row][column + 1]);
        player.indexColumn = 0;
        continue;
      }
    }
  }
}

class DarkAgeAreaUnderground extends GameDarkAge {

  @override
  bool get customPropMapVisible => false;

  var mapTile = 0;
  DarkAgeAreaUnderground(Scene scene, {required this.mapTile})
      : super(scene, engine.environmentUnderground);
}