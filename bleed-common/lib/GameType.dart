enum GameType {
    None,
    MMO,
    Moba,
    BATTLE_ROYAL,
    SKIRMISH,
    CUBE3D,
    DeathMatch,
    Custom
}

final List<GameType> gameTypes = GameType.values;

final Map<GameType, String> gameTypeNames = {
    GameType.MMO: "SANDBOX",
    GameType.BATTLE_ROYAL: "ROYAL",
    GameType.CUBE3D: "CUBE 3D",
    GameType.Moba: "HEROES MOBA",
    GameType.DeathMatch: "COUNTER STRIKE",
};

final List<GameType> freeToPlay = [
    GameType.MMO,
    GameType.Moba,
    GameType.BATTLE_ROYAL,
];