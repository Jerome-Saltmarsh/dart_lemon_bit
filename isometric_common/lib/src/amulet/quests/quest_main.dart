enum QuestMain {
  Speak_With_Warren('speak with warren in the village'),
  Kill_The_Witch('find the witches lair and kill her'),
  Return_To_Warren('return to the village and speak with warren'),
  Completed('quest completed');
  final String instructions;
  const QuestMain(this.instructions);
}
