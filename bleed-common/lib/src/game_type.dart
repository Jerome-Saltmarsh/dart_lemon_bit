enum GameType {
  Website,
  Editor,
  Combat,
  Rock_Paper_Scissors,
  Mobile_Aeon,
  Fight2D,
  Aeon,
  Cube3D,
  CastleStorm,
  Capture_The_Flag,
}

extension GameTypeExtension on GameType {

  bool get isSinglePlayer {
    return const [
      GameType.Cube3D,
    ].contains(this);
  }
}