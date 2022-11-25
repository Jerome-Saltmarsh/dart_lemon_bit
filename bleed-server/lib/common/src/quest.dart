
enum Quest {
  Jenkins_Retrieve_Stolen_Scroll,
  Jenkins_Return_Stole_Scroll_To_Jenkins,
  Jenkins_Deliver_Scroll_To_College,
  Garry_Kill_Farm_Zombies,
  Garry_Return_To_Garry,
  Rufus_Dark_Fortress_Lost_Treasure,
}

const quests = Quest.values;

const questDescription = <Quest, String> {
  Quest.Jenkins_Retrieve_Stolen_Scroll: 'Go to the old forest south west of the tavern and recover the stolen scroll from the bandits',
  Quest.Jenkins_Return_Stole_Scroll_To_Jenkins: 'Return the scroll to Jenkins who is waiting in the old tavern',
  Quest.Jenkins_Deliver_Scroll_To_College: 'Deliver the scroll you obtained from the bandits to the high seer in the university',
  Quest.Garry_Return_To_Garry: 'I should return to Garry waiting outside the Tavern for my reward',
  Quest.Garry_Kill_Farm_Zombies: 'Garry has asked me to go to the farmlands north of the Inn and kill 10 zombies',
  Quest.Rufus_Dark_Fortress_Lost_Treasure: 'According to Rufus, there is a hidden chamber inside of the dark castle containing a special power',
};

const questName = <Quest, String> {
  Quest.Jenkins_Retrieve_Stolen_Scroll: 'The Stolen Scroll',
  Quest.Jenkins_Return_Stole_Scroll_To_Jenkins: 'The Stolen Scroll',
  Quest.Jenkins_Deliver_Scroll_To_College: 'The Stolen Scroll',
  Quest.Garry_Return_To_Garry: 'Zombie Farm',
  Quest.Garry_Kill_Farm_Zombies: 'Zombie Farm',
  Quest.Rufus_Dark_Fortress_Lost_Treasure: 'Secret Powers',
};
