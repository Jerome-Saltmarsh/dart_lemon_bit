import '../../classes/player.dart';
import '../../common/quest.dart';

void onInteractionWithJenkins(Player player) {

  const Retrieve_Stolen_Scroll = Quest.Jenkins_Retrieve_Stolen_Scroll;

  if (player.questInProgress(Retrieve_Stolen_Scroll))
     return player.interact(
         message: "Did you manage to get my scroll back from the bandits yet?",
         responses: {
           "Yes here it is": () {
              player.completeQuest(Retrieve_Stolen_Scroll);
              player.interact(message: "You found it! Thank you so much");
           },
           "Where did you say the bandits hideout was?": (){
             player.interact(
                 message: 'In the old forest directly south east of this village. Please hurry and bring back my scroll',
             );
           },
           "Not yet": player.endInteraction,
         }
     );

  if (player.questCompleted(Retrieve_Stolen_Scroll))
    return player.interact(
        message: "Thank you for all your help kind stranger",
        responses: {
          "Glad to help": player.endInteraction
        }
    );

  player.interact(
    message: "What should I do?! What should I do?!!",
    responses: {
      "What's wrong?": () {
        player.interact(
          message: "I was on my way to the college to deliver a very important scroll when a group of bandits robbed me of all my possessions",
          responses: {
              "Let me help you": () {
              player.beginQuest(Retrieve_Stolen_Scroll);
              player.interact(
                  message: "Would you really? Thank you so much! The bandits hideout is in the old forest directly south east of this village. Its dangerous so make sure you are properly equipped before you go there. If you manage to recover the scroll please bring it directly back to me",
                  responses: {
                    "Where can I get some equipment": player.endInteraction,
                    "I better get going": player.endInteraction,
                  }
              );
            },
            "Sorry I'm busy": player.endInteraction,
          },
        );
      },
    },
  );
}
