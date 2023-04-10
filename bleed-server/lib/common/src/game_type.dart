class GameType {
  static const Editor               = 1;
  static const Practice             = 2;
  static const Survival             = 3;
  static const Combat               = 4;
  static const Rock_Paper_Scissors  = 5;

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
      Combat    : 'Combat'    ,
      Rock_Paper_Scissors: "Rock Paper Scissors",
  } [value] ?? 'Unknown ($value)';
}
