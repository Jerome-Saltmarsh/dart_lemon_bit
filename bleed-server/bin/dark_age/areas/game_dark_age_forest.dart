
import '../../classes/library.dart';
import '../../common/flag.dart';
import '../../common/quest.dart';
import '../../engine.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeForest extends DarkAgeArea {
  GameDarkAgeForest() : super(darkAgeScenes.forest){

    addNpc(
       name: "Roy",
       row: 21,
       column: 38,
       z: 1,
       onInteractedWith: (Player player){
           if (player.flag(Flag.Encountered_Roy)) {
               return player.interact(
                   message: "Who might you be? Don't you know its dangerous wandering around these woods? There could be thieves and who knows what else lurking about.",
                   responses: {
                      "I'm lost": (){},
                      if (player.questInProgress(Quest.Jenkins_Retrieve_Stolen_Scroll))
                        "I'm searching for the thieves that stole the old man's scroll": (){

                        },
                   }
               );
           }
       }
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