class GameType {
  static const Dark_Age = 0;
  static const Editor = 1;
  static const Waves = 3;
  static const Skirmish = 4;

  static const values = [
     Dark_Age,
     Editor,
     Waves,
     Skirmish,
  ];
  
  static String getName(int value) => const {
      Dark_Age: "Dark Age",
      Editor: "Editor",
      Waves: "Waves",
      Skirmish: "Skirmish",
  } [value] ?? "Unknown ($value)";
}
