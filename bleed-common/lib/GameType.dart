enum GameType { None, MMO, Moba, CUBE3D }

final List<GameType> gameTypes = GameType.values;

final List<GameType> selectableGameTypes =
    gameTypes.where((value) => value != GameType.None).toList();


final Map<GameType, String> gameTypeNames = {
    GameType.Moba: "HEROES LEAGUE",
    GameType.MMO: "ATLAS ONLINE",
    GameType.CUBE3D: "CUBE 3D",
};
