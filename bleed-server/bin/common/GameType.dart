class GameType {
  static const Dark_Age = 0;
  static const Editor = 1;
  static const Arena = 2;
  static const Waves = 3;

  static const values = [
     Dark_Age,
     Editor,
     Arena,
     Waves,
  ];
  
  static String getName(int value) => const {
      Dark_Age: "Dark Age",
      Editor: "Editor",
      Arena: "Arena",
      Waves: "Waves",
  } [value] ?? "Unknown ($value)";
}
