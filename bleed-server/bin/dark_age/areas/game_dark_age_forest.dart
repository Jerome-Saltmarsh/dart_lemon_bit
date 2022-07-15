
import 'package:lemon_math/library.dart';

import '../../classes/library.dart';
import '../../common/flag.dart';
import '../../common/library.dart';
import '../../common/quest.dart';
import '../../engine.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeForest extends DarkAgeArea {
  GameDarkAgeForest() : super(darkAgeScenes.forest, mapX: 1, mapY: 0){

    addEnemySpawn(z: 1, row: 8, column: 16, health: 5, max: 3);

    addNpc(
       name: "Roy",
       row: 21,
       column: 38,
       z: 1,
       wanderRadius: 2,
       onInteractedWith: (Player player){
           if (player.flag(Flag.Encountered_Roy)) {
               return player.interact(
                   message: "Aye who might you be? Don't you know its dangerous wandering about these woods? Could be thieves and who knows what else lurking about.",
                   responses: {
                      "I'm lost": player.endInteraction,
                      if (player.questInProgress(Quest.Jenkins_Retrieve_Stolen_Scroll))
                        "I'm searching for the thieves that stole the old man's scroll": (){
                            player.completeQuest(Quest.Jenkins_Retrieve_Stolen_Scroll);
                            player.interact(
                                message: "This worthless old piece of paper you mean? Its covered in all these old symbols but it doesn't make any sense to me. Here take it.",
                            );
                        },
                   }
               );
           }
       }
    );

    addNpc(
        name: "Bandit",
        row: 20,
        column: 35,
        z: 1,
        weaponType: WeaponType.Bow,
        head: randomItem(HeadType.values),
        armour: randomItem(ArmourType.values),
        pants: randomItem(PantsType.values),
        wanderRadius: 1,
    );

    addNpc(
      name: "Bandit",
      row: 20,
      column: 43,
      z: 1,
      weaponType: WeaponType.Sword,
      head: randomItem(HeadType.values),
      armour: randomItem(ArmourType.values),
      pants: randomItem(PantsType.values),
      wanderRadius: 2,
    );

    addNpc(
      name: "Bandit",
      row: 23,
      column: 36,
      z: 1,
      weaponType: WeaponType.Axe,
      head: randomItem(HeadType.values),
      armour: randomItem(ArmourType.values),
      pants: randomItem(PantsType.values),
      wanderRadius: 2,
    );
  }


  @override
  void updateInternal() {
    for (var i = 0; i < players.length; i++) {
      final player = players[i];
      final row = player.indexRow;
      final column = player.indexColumn;

      if (row == 0 && (column == 6 || column == 7)) {
        player.changeGame(engine.findGameDarkAgeVillage());
        player.indexRow = 48;
        continue;
      }
    }
  }
}