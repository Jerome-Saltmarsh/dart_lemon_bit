import '../../classes/player.dart';
import '../../common/quest.dart';

void onInteractWithJenkins(Player player) {

  if (player.questToDo(Quest.Jenkins_Retrieve_Stolen_Scroll))
    return toDoJenkinsRetrieveStolenScroll(player);

  if (player.questInProgress(Quest.Jenkins_Retrieve_Stolen_Scroll))
    return inProgressJenkinsRetrieveStolenScroll(player);

  if (player.questInProgress(Quest.Jenkins_Return_Stole_Scroll_To_Jenkins)) {
    player.completeQuest(Quest.Jenkins_Return_Stole_Scroll_To_Jenkins);
    player.beginQuest(Quest.Jenkins_Deliver_Scroll_To_College);
    return player.interact(
      message: "Fantastic you have recovered the scroll! I have another favour to ask of you. That scroll needs to be delivered to the College is Westhorn, considering you capabilities would you be so kind as to deliver it for me?",
    );
  }


  if (player.questInProgress(Quest.Jenkins_Deliver_Scroll_To_College))
    return inProgressJenkinsDeliverScroll(player);

  return interactionJenkinsAllQuestsCompleted(player);
}

void toDoJenkinsRetrieveStolenScroll(Player player) {
  return player.interact(
    message: "What should I do?! What should I do?!!",
    responses: {
      "What's wrong?": () {
        player.interact(
          message: "I was on my way to the college to deliver a very important scroll when a group of bandits robbed me of all my possessions",
          responses: {
            "Let me help you (QUEST)": () {
              player.beginQuest(Quest.Jenkins_Retrieve_Stolen_Scroll);
              player.interact(
                  message: "Would you really? Thank you so much! The bandits hideout is in the old forest directly south east of this village. Its dangerous so make sure you are properly equipped before you go there. If you manage to recover the scroll please bring it directly back to me",
                  responses: {
                    "I better get going": player.endInteraction,
                    "Got any hints?": (){
                       player.interact(message: "Their leader called himself Roy, claimed he was the most revered thief in all Spire");
                    },
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

void inProgressJenkinsRetrieveStolenScroll(Player player) {
  return player.interact(
      message: "Did you manage to get my scroll back from the bandits yet?",
      responses: {
        "Yes here it is": () {
          player.completeQuest(Quest.Jenkins_Retrieve_Stolen_Scroll);
          player.interact(
              message: "Fantastic! You have truly saved me. Actually a thought just occurred to me. Considering you are younger and faster than I would you please deliver that scroll to the college for me?",
              responses: {
                "Sure thing!" : () => beginQuestJenkinsDeliverScroll(player),
                "Sorry, I don't have time" : player.endInteraction
              }
          );
        },
        "Where did you say the bandits hideout was?": (){
          player.interact(
              message: 'In the old forest directly south east of this village. Please hurry and bring back my scroll',
          );
        },
        "Not yet": player.endInteraction,
      }
  );
}

void questToDoJenkinsDeliverScroll(Player player) =>
    player.interact(
        message: "Could you please deliver the scroll to the college for me?",
        responses: {
          "Sure no problem": () => beginQuestJenkinsDeliverScroll(player),
          "Sorry I don't have time": player.endInteraction
        }
    );

void beginQuestJenkinsDeliverScroll(Player player){
  player.beginQuest(Quest.Jenkins_Deliver_Scroll_To_College);
  player.interact(
    message: "Thank you stranger for all of your kindness. The college is south west of here. Please deliver it as quickly as possible",
    responses: {
      "Goodbye" : player.endInteraction,
    }
  );
}

void inProgressJenkinsDeliverScroll(Player player) =>
  player.interact(
    message: "Please hurry! Its of vital importance that you deliver that scroll to the college.",
    responses: {
      "Where is the college?": () {
         player.interact(message: "Directly south west of here");
      },
      "I'll be off then" : player.endInteraction,
    }
  );

void interactionJenkinsAllQuestsCompleted(Player player) {
  return player.interact(
      message: "Thank you for all your help kind stranger",
      responses: {
        "Glad to help": player.endInteraction
      }
  );
}
