class GameType {
  static const Editor               = 1;
  static const Combat               = 4;
  static const Rock_Paper_Scissors  = 5;
  static const Mobile_Aeon          = 6;
  static const Fight2D              = 7;

  static String getName(int? value) => value == null ? 'None' : const {
      Editor    : 'Editor'    ,
      Combat    : 'Combat'    ,
      Rock_Paper_Scissors: "Rock Paper Scissors",
      Mobile_Aeon: "Mobile Aeon",
      Fight2D: "FIGHT 2D",
  } [value] ?? 'Unknown ($value)';
}
