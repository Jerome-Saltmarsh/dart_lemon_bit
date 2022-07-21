
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
             "I was asked to deliver this (QUEST)": () {
                player.completeQuest(Quest.Jenkins_Deliver_Scroll_To_College);
                player.beginQuest(Quest.Rufius_Dark_Fortress_Lost_Treasure);
                player.interact(
                    message: "Whats this?! How Intriguing! This a scroll written in the ancient language. According to this there is a hidden chamber deep within the Dark Castle containing an ancient power",
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