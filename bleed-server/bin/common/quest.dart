
enum Quest {
  Jenkins_Retrieve_Stolen_Scroll,
  Jenkins_Return_Stole_Scroll_To_Jenkins,
  Jenkins_Deliver_Scroll_To_College,
}

const quests = Quest.values;

const questDescription = <Quest, String> {
  Quest.Jenkins_Retrieve_Stolen_Scroll: "Go to the old forest south west of the tavern and recover the stolen scroll from the bandits",
  Quest.Jenkins_Return_Stole_Scroll_To_Jenkins: "Return the scroll to Jenkins who is waiting in the old tavern",
  Quest.Jenkins_Deliver_Scroll_To_College: "Deliver the scroll you obtained from the bandits to the high seer in the university"
};

const questName = <Quest, String> {
  Quest.Jenkins_Retrieve_Stolen_Scroll: "The Stolen Scroll",
  Quest.Jenkins_Return_Stole_Scroll_To_Jenkins: "The Stolen Scroll",
  Quest.Jenkins_Deliver_Scroll_To_College: "The Stolen Scroll",
};
