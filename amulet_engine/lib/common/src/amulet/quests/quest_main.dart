enum QuestMain {
  Speak_With_Gareth('Speak with Gareth by the campfire in the village'),
  Kill_The_Witch('Find the witches lair and kill her'),
  Return_To_Gareth('Return to the village and speak with Gareth'),
  Completed('Quest completed');
  final String instructions;
  const QuestMain(this.instructions);
}
