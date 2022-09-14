
import 'package:lemon_math/library.dart';

import '../../classes/library.dart';
import '../../common/attack_type.dart';
import '../../common/flag.dart';
import '../../common/library.dart';
import '../../common/map_tiles.dart';
import '../../common/quest.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaForest4 extends DarkAgeArea {
  AreaForest4() : super(darkAgeScenes.forest_4, mapTile: MapTiles.Forest_4) {
    addNpc(
        name: "Roy",
        row: 12,
        column: 33,
        z: 1,
        wanderRadius: 20,
        weapon: buildWeaponBow(),
        onInteractedWith: (Player player) {
          return player.interact(
              message:
              player.flag(Flag.Encountered_Roy) ?
              "Aye who might you be? Don't you know its dangerous wandering about these woods? Could be thieves and who knows what else lurking about." :
              "Hello there",
              responses: {
                "I'm lost": player.endInteraction,
                if (player.questInProgress(Quest.Jenkins_Retrieve_Stolen_Scroll))
                  "I'm looking for an old scroll (QUEST)":
                      () {
                    player.completeQuest(Quest.Jenkins_Retrieve_Stolen_Scroll);
                    player.beginQuest(
                        Quest.Jenkins_Return_Stole_Scroll_To_Jenkins);
                    player.interact(
                      message:
                      "This worthless old piece of paper you mean? Its covered in all these old symbols but it doesn't make any sense to me. Here take it.",
                    );
                  },
                if (player.questInProgress(Quest.Jenkins_Deliver_Scroll_To_College))
                  "Can you tell me how to get to the old college?": (){
                    player.interact(message: "Follow the road north, once you hit the tavern go west");
                  },
              });
        });

    addNpc(
      name: "Bandit",
      row: 18,
      column: 33,
      z: 1,
      weapon:  buildWeaponBow(),
      head: randomItem(HeadType.values),
      armour: randomItem(ArmourType.values),
      pants: randomItem(PantsType.values),
      wanderRadius: 25,
    );

    addNpc(
      name: "Bandit",
      row: 18,
      column: 35,
      z: 1,
      weapon: buildWeaponBow(),
      head: randomItem(HeadType.values),
      armour: randomItem(ArmourType.values),
      pants: randomItem(PantsType.values),
      wanderRadius: 20,
    );

    addNpc(
      name: "Bandit",
      row: 12,
      column: 37,
      z: 1,
      weapon: buildWeaponBow(),
      head: randomItem(HeadType.values),
      armour: randomItem(ArmourType.values),
      pants: randomItem(PantsType.values),
      wanderRadius: 10,
    );
  }

}