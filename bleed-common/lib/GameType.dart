enum GameType { None, MMO, Moba }

final List<GameType> gameTypes = GameType.values;

final List<GameType> selectableGameTypes =
    gameTypes.where((value) => value != GameType.None).toList();


final Map<GameType, String> gameTypeNames = {
    GameType.Moba: "HEROES LEAGUE",
    GameType.MMO: "ATLAS ONLINE",
};
