class GameType {
  static const Dark_Age = 0;
  static const Editor = 1;
  static const Practice = 2;
  /// Spawn somewhere in the wilderness
  /// The goal is to survive for as long as possible
  /// Scavenge the land looking for loot
  /// All other players are your enemy
  /// Treasures appear on the map but watch out for other players who might also be after it
  static const Survival = 3;
  static const FiveVFive = 4;

  static const values = [
     Dark_Age,
     Editor,
     Practice,
     Survival,
     FiveVFive,
  ];

  static String getName(int? value) => value == null ? 'None' : const {
      Dark_Age  : 'Dark Age'  ,
      Editor    : 'Editor'    ,
      Practice  : 'Practice'  ,
      Survival  : 'Survival'  ,
      FiveVFive : '5v5'       ,
  } [value] ?? 'Unknown ($value)';
}
