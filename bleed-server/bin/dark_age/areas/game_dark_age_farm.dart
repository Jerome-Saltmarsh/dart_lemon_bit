
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
        row: 25,
        column: 20,
        z: 3,
        onInteractedWith: (player){
           player.interact(message: "I've been seeing more and more monsters in the wilderness lately");
        },
        wanderRadius: 80,
    );

    // gameObjects.add(GameObjectButterfly(x: 1125, y: 1000, z: 80));
    // gameObjects.add(GameObjectButterfly(x: 600, y: 980, z: 124));
    // gameObjects.add(GameObjectButterfly(x: 500, y: 800, z: 100));
    // gameObjects.add(GameObjectButterfly(x: 925, y: 1250, z: 80));
    // gameObjects.add(GameObjectButterfly(x: 1850, y: 1035, z: 50));
    // gameObjects.add(GameObjectChicken(x: 1720, y: 720, z: 72));
    // gameObjects.add(GameObjectChicken(x: 1500, y: 1220, z: 74));
    // gameObjects.add(GameObjectChicken(x: 2285, y: 880, z: 48));
    // gameObjects.add(GameObjectCrystal(x: 740, y: 1030, z: 120)..movable = false);
    //
    // gameObjects.add(GameObjectRock(x: 1615, y: 470, z: 72)..movable = false);
    // gameObjects.add(GameObjectRock(x: 2630, y: 1000, z: 72)..movable = false);
    // gameObjects.add(GameObjectStick(x: 2500, y: 405, z: 72));
    // gameObjects.add(GameObjectFlower(x: 1700, y: 1200, z: 72));
    // gameObjects.add(GameObjectFlower(x: 1220, y: 850, z: 97));
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