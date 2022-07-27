
import '../../classes/library.dart';
import '../../common/map_tiles.dart';
import '../../common/quest.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeFarm extends DarkAgeArea {
  GameDarkAgeFarm() : super(darkAgeScenes.farm, mapTile: MapTiles.Farm) {
      // addEnemySpawn(z: 1, row: 34, column: 30, health: 5, max: 5, wanderRadius: 300);
      // addEnemySpawn(z: 1, row: 12, column: 9, health: 5, max: 10, wanderRadius: 300);
    addNpc(
        name: "Magellan",
        row: 27,
        column: 18,
        z: 3,
        onInteractedWith: (player){
           player.interact(message: 'hello there');
        }
    );
  }

  @override
  void onPlayerJoined(Player player) {
    player.indexZ = 4;
    player.indexRow = 14;
    player.indexColumn = 19;
  }

  @override
  void onKilled(dynamic target, dynamic src){
     if (src is Player){
        if (src.questInProgress(Quest.Garry_Kill_Farm_Zombies)){
           src.questZombieKillsRemaining--;
           if (src.questZombieKillsRemaining <= 0){
             src.completeQuest(Quest.Garry_Kill_Farm_Zombies);
             src.beginQuest(Quest.Garry_Return_To_Garry);
           }
        }
     }
  }
}