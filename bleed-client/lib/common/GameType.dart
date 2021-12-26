enum GameType { None, MMO, Moba, BATTLE_ROYAL, CUBE3D }

final List<GameType> gameTypes = GameType.values;

final List<GameType> selectableGameTypes = [
    GameType.Moba,
    GameType.MMO,
    GameType.CUBE3D,
    GameType.BATTLE_ROYAL,
];

final Map<GameType, String> gameTypeNames = {
    GameType.Moba: "HEROES LEAGUE",
    GameType.MMO: "ATLAS ONLINE",
    GameType.CUBE3D: "CUBE 3D",
    GameType.BATTLE_ROYAL: "ZOMBIE ROYAL",
};
