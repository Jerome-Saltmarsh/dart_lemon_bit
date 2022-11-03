class GameType {
  static const Dark_Age = 0;
  static const Editor = 1;
  static const Skirmish = 4;

  static const values = [
     Dark_Age,
     Editor,
     Skirmish,
  ];

  static bool isTimed(int gameType) => const [
      Dark_Age,
      Editor,
  ].contains(gameType);

  static String getName(int? value) => value == null ? 'None' : const {
      Dark_Age: 'Dark Age',
      Editor: 'Editor',
      Skirmish: 'Skirmish',
  } [value] ?? 'Unknown ($value)';
}
