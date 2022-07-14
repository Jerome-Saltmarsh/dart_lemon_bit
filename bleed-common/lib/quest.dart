
enum Quest {
  Jenkins_Retrieve_Stolen_Scroll,
  Jenkins_Deliver_Stolen_Scroll,
}

const quests = Quest.values;

const questDescription = <Quest, String> {
  Quest.Jenkins_Retrieve_Stolen_Scroll: "Go to the old forest south west of the tavern and recover the stolen scroll from the bandits",
  Quest.Jenkins_Deliver_Stolen_Scroll: "Deliver the scroll you obtained from the bandits to the high seer in the university"
};

const questName = <Quest, String> {
  Quest.Jenkins_Retrieve_Stolen_Scroll: "The Stolen Scroll",
  Quest.Jenkins_Deliver_Stolen_Scroll: "Deliver the Scroll",
};
