enum QuestMain {
  Speak_With_Gareth('Speak with Gareth by the campfire in the village'),
  Find_Witches_Lair("Find the entrance to the witch's lair in the Lost Swamps"),
  Kill_The_Witch("Kill the witch"),
  Return_To_Gareth('Return to the village and speak with Gareth'),
  Completed('Demo Completed');
  final String instructions;
  const QuestMain(this.instructions);
}
