enum GameType {
    None,
    MMO,
    Moba,
    BATTLE_ROYAL,
    CUBE3D,
    DeathMatch,
    Custom
}

final List<GameType> gameTypes = GameType.values;

final List<GameType> selectableGameTypes = [
    GameType.MMO,
    GameType.Moba,
    GameType.BATTLE_ROYAL,
    GameType.CUBE3D,
    GameType.DeathMatch,
];

final Map<GameType, String> gameTypeNames = {
    GameType.Moba: "HEROES MOBA",
    GameType.MMO: "BLEED MMO",
    GameType.CUBE3D: "CUBE 3D",
    GameType.BATTLE_ROYAL: "ZOMBIE ROYAL",
    GameType.DeathMatch: "COUNTER STRIKE",
};

final List<GameType> freeToPlay = [
    GameType.MMO,
    GameType.Moba,
    GameType.BATTLE_ROYAL,
];