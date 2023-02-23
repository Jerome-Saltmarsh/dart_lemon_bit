class GameType {
  static const Editor = 1;
  static const Practice = 2;
  static const Survival = 3;
  /// Intense Action
  static const Combat = 4;

  static const values = [
     Editor,
     Practice,
     Survival,
     Combat,
  ];

  static String getName(int? value) => value == null ? 'None' : const {
      Editor    : 'Editor'    ,
      Practice  : 'Practice'  ,
      Survival  : 'Survival'  ,
      Combat : 'Combat',
  } [value] ?? 'Unknown ($value)';
}
