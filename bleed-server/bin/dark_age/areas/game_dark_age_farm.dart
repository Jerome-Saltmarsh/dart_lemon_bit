
import '../../classes/gameobject.dart';
import '../../classes/library.dart';
import '../../common/map_tiles.dart';
import '../../common/quest.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeFarm extends DarkAgeArea {
  GameDarkAgeFarm() : super(darkAgeScenes.farm, mapTile: MapTiles.Farm) {
    addNpc(
        name: "Magellan",
        row: 27,
        column: 18,
        z: 3,
        onInteractedWith: (player){
           player.interact(message: "I've been seeing more and more monsters in the wilderness lately");
        }
    );
    
    gameObjects.add(GameObjectRock(x: 1125, y: 874, z: 72));
    gameObjects.add(GameObjectFlower(x: 1125, y: 774, z: 72));
    gameObjects.add(GameObjectFlower(x: 695, y: 1030, z: 97));
    gameObjects.add(GameObjectFlower(x: 1500, y: 330, z: 76));
    gameObjects.add(GameObjectStick(x: 1125, y: 1000, z: 72));
    gameObjects.add(GameObjectButterfly(x: 1125, y: 1000, z: 80));
    gameObjects.add(GameObjectButterfly(x: 600, y: 980, z: 124));
    gameObjects.add(GameObjectButterfly(x: 500, y: 800, z: 100));
    gameObjects.add(GameObjectButterfly(x: 925, y: 1250, z: 80));
    gameObjects.add(GameObjectChicken(x: 1455, y: 945, z: 72));
    gameObjects.add(GameObjectChicken(x: 1600, y: 600, z: 74));
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