class GameType {
  static const Dark_Age = 0;
  static const Editor = 1;
  static const Practice = 2;
  static const Survival = 3;
  /// Intense Action
  static const Skirmish = 4;

  static const values = [
     Dark_Age,
     Editor,
     Practice,
     Survival,
      Skirmish,
  ];

  static String getName(int? value) => value == null ? 'None' : const {
      Dark_Age  : 'Dark Age'  ,
      Editor    : 'Editor'    ,
      Practice  : 'Practice'  ,
      Survival  : 'Survival'  ,
      Skirmish : 'Skirmish',
  } [value] ?? 'Unknown ($value)';
}
