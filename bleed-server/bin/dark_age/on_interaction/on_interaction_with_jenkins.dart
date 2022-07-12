import '../../classes/player.dart';
import '../../common/quest.dart';

void onInteractionWithJenkins(Player player) {

  if (player.questInProgress(Quest.Jenkins_Retrieve_Stolen_Scroll))
     return player.writeNpcTalk(
         text: "Did you manage to get my scroll back?",
         options: {
           "Yes here it is": () {},
           "Where did you say the bandits were?": (){},
           "Not yet": () {},
         }
     );

  if (player.questCompleted(Quest.Jenkins_Retrieve_Stolen_Scroll))
    return player.writeNpcTalk(
        text: "Thank you for all your help kind stranger",
        options: {
          "Glad to help": player.stopInteractingWithNpc
        }
    );

  player.writeNpcTalk(
    text: "What should I do?! What should I do?!!",
    options: {
      "What's wrong?": () {
        player.writeNpcTalk(
          text: "I was on my way to the college to deliver a very important scroll when a group of bandits robbed me of all my possessions including the scroll",
          options: {
              "Let me help you": () {
              player.questsInProgress.add(Quest.Jenkins_Retrieve_Stolen_Scroll);
              player.writeNpcTalk(
                  text: "Would you really? Thank you so much! The bandits hideout is in the old forest directly south east of this village. If you manage to recover the scroll please bring it directly back to me",
                  options: {
                    "I better get going": player.stopInteractingWithNpc,
                  }
              );
            },
            "Sorry I'm busy": player.stopInteractingWithNpc,
          },
        );
      },
    },
  );
}
