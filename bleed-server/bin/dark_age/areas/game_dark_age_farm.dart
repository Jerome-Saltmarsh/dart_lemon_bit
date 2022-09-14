
import 'package:lemon_math/library.dart';

import '../../classes/library.dart';
import '../../common/library.dart';
import '../../common/map_tiles.dart';
import '../../common/quest.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeFarm extends DarkAgeArea {
  GameDarkAgeFarm() : super(darkAgeScenes.farm, mapTile: MapTiles.Farm) {
    addNpc(
       weapon: buildWeaponBow(),
        name: "Magellan",
        row: 28,
        column: 21,
        z: 3,
        onInteractedWith: (player) =>
           player.interact(message: "Its risky to go out into the wilderness but that's where one finds the loots"),
        wanderRadius: 50,
    );

    addNpc(
      weapon: buildWeaponBow(),
      name: "Sammy",
      row: 28,
      column: 15,
      z: 3,
      onInteractedWith: (player){
        player.interact(message: "Hi Dear");
      },
      wanderRadius: 5,
      head: HeadType.Blonde,
      armour: ArmourType.tunicPadded,
    );
  }

  @override
  void onPlayerJoined(Player player) {
    player.indexZ = 5;
    if (randomBool()){
      player.indexRow = 16;
      player.indexColumn = 21;
    } else {
      player.indexRow = 15;
      player.indexColumn = 22;
    }
    const radius = 5.0;
    player.x += giveOrTake(radius);
    player.y += giveOrTake(radius);
    player.setCharacterStateSpawning();

    player. interact(
        message: "Welcome to Dark-Age! \n\nUse the W,A,S,D keys to run \nLeft and right mouse click to attack and interact",
        responses: {
          "Okay!": player.endInteraction,
        }
    );
  }

  @override
  void onKilled(dynamic target, dynamic src){
     if (src is Player){
        if (src.questInProgress(Quest.Garry_Kill_Farm_Zombies)){
        }
     }
  }
}