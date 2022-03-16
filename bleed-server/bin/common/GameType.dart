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

const gameTypes = GameType.values;

const gameTypeNames = {
    GameType.MMO: "SANDBOX",
    GameType.SKIRMISH: "SKIRMISH",
    GameType.BATTLE_ROYAL: "ROYAL",
    GameType.CUBE3D: "CUBE 3D",
    GameType.Moba: "HEROES MOBA",
    GameType.DeathMatch: "COUNTER STRIKE",
};

const freeToPlay = [
    GameType.MMO,
    GameType.Moba,
    GameType.BATTLE_ROYAL,
];