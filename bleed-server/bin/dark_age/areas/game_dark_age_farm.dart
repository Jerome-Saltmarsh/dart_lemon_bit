
import 'package:lemon_math/library.dart';

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
        },
        wanderRadius: 80,
    );
    
    gameObjects.add(GameObjectRock(x: 1125, y: 874, z: 72));
    gameObjects.add(GameObjectFlower(x: 1125, y: 774, z: 72));
    gameObjects.add(GameObjectFlower(x: 695, y: 1030, z: 97));
    gameObjects.add(GameObjectFlower(x: 1500, y: 330, z: 76));
    gameObjects.add(GameObjectFlower(x: 2000, y: 560, z: 49));
    gameObjects.add(GameObjectStick(x: 1125, y: 1000, z: 72));
    gameObjects.add(GameObjectButterfly(x: 1125, y: 1000, z: 80));
    gameObjects.add(GameObjectButterfly(x: 600, y: 980, z: 124));
    gameObjects.add(GameObjectButterfly(x: 500, y: 800, z: 100));
    gameObjects.add(GameObjectButterfly(x: 925, y: 1250, z: 80));
    gameObjects.add(GameObjectButterfly(x: 1850, y: 1035, z: 50));
    gameObjects.add(GameObjectChicken(x: 1455, y: 945, z: 72));
    gameObjects.add(GameObjectChicken(x: 1600, y: 600, z: 74));
    gameObjects.add(GameObjectChicken(x: 2115, y: 835, z: 48));
    gameObjects.add(GameObjectCrystal(x: 740, y: 1030, z: 120)..movable = false);
  }

  @override
  void onPlayerJoined(Player player) {
    player.indexZ = 5;
    player.indexRow = 15;
    player.indexColumn = 21;
    const radius = 30.0;
    player.x += giveOrTake(radius);
    player.y += giveOrTake(radius);
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