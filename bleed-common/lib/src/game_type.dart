enum GameType {
  Website,
  Editor,
  Combat,
  Rock_Paper_Scissors,
  Mobile_Aeon,
  Fight2D,
  Cube3D,
  Moba,
  Capture_The_Flag,
  Mmo,
}

extension GameTypeExtension on GameType {

  bool get isSinglePlayer {
    return const [
      GameType.Cube3D,
    ].contains(this);
  }
}