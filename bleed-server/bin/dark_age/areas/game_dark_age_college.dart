
import '../../classes/game.dart';
import '../../classes/player.dart';
import '../../common/quest.dart';
import '../../engine.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeCollege extends DarkAgeArea {
  GameDarkAgeCollege() : super(darkAgeScenes.castle, mapX: 0, mapY: 1) {
    addNpc(
      name: "Professor Rufius",
      row: 15,
      column: 30,
      z: 1,
      onInteractedWith: (Player player){

        player.interact(message: "Salutations", responses: {
           if (player.questInProgress(Quest.Jenkins_Deliver_Scroll_To_College))
             "I was asked to deliver this (QUEST)": (){
                player.completeQuest(Quest.Jenkins_Deliver_Scroll_To_College);
                player.interact(
                    message: "Whats this?! These symbols... could it be! How fascinating, who would have thought? I will need to do some tests, you there, I required 5 mushrooms for my very important research, bring them at once",
                );
             },
             "What is this place?": (){
                 player.interact(message: "You are standing in the sacred College");
             },
             "Never mind": player.endInteraction
        });

      }
    );
  }

  @override
  void updateInternal(){
    var playerLength = players.length;
    for (var i = 0; i < playerLength; i++) {
      final player = players[i];
      if (player.indexColumn == 0 && (player.indexRow == 19 || player.indexRow == 18)) {
        player.changeGame(engine.findGameDarkAgeVillage());
        player.indexColumn = player.game.scene.gridColumns - 2;
        i--;
        playerLength--;
      }
    }
  }
}