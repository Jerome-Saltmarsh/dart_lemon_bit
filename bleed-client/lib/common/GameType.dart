enum GameType {
    None,
    MMO,
    Moba,
    BATTLE_ROYAL,
    CUBE3D,
    TACTICAL_COMBAT,
}

final List<GameType> gameTypes = GameType.values;

final List<GameType> selectableGameTypes = [
    GameType.MMO,
    GameType.Moba,
    GameType.BATTLE_ROYAL,
    GameType.CUBE3D,
    GameType.TACTICAL_COMBAT,
];

final Map<GameType, String> gameTypeNames = {
    GameType.Moba: "HEROES LEAGUE",
    GameType.MMO: "ATLAS ONLINE",
    GameType.CUBE3D: "CUBE 3D",
    GameType.BATTLE_ROYAL: "ZOMBIE ROYAL",
    GameType.TACTICAL_COMBAT: "COUNTER STRIKE",
};
