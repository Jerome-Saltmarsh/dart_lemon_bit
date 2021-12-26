enum GameType { None, MMO, Moba, HUNTER, CUBE3D }

final List<GameType> gameTypes = GameType.values;

final List<GameType> selectableGameTypes = [
    GameType.Moba,
    GameType.MMO,
    GameType.CUBE3D,
    GameType.HUNTER,
];

final Map<GameType, String> gameTypeNames = {
    GameType.Moba: "HEROES LEAGUE",
    GameType.MMO: "ATLAS ONLINE",
    GameType.CUBE3D: "CUBE 3D",
    GameType.HUNTER: "HUNTER",
};
