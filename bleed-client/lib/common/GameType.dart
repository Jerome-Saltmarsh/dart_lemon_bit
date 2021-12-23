enum GameType { None, Open_World, Moba }

final List<GameType> gameTypes = GameType.values;

final List<GameType> selectableGameTypes =
    gameTypes.where((value) => value != GameType.None).toList();
