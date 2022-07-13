
enum Quest {
  Jenkins_Retrieve_Stolen_Scroll,
  Jenkins_Deliver_Stolen_Scroll,
  Garry_Acquire_Weapon,
}

const quests = Quest.values;

const questDescription = <Quest, String> {
  Quest.Jenkins_Retrieve_Stolen_Scroll: "Go to the old forest south west of the tavern and recover the stolen scroll from the bandits"
};

const questName = <Quest, String> {
  Quest.Jenkins_Retrieve_Stolen_Scroll: "The Stolen Scroll"
};
