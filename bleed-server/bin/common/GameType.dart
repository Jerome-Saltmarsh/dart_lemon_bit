enum GameType {
    None,
    MMO,
    Moba,
    BATTLE_ROYAL,
    SKIRMISH,
    RANDOM,
    RANDOM_SOLO,
    BATTLE_SOLO,
    BATTLE_TEAMS_2V2V2,
    BATTLE_SANDBOX,
    SWARM,
    CUBE3D,
    DeathMatch,
    Custom
}

const gameTypes = GameType.values;

const gameTypeNames = {
    GameType.MMO: "ADVENTURE",
    GameType.SKIRMISH: "SKIRMISH",
    GameType.BATTLE_ROYAL: "ROYAL",
    GameType.CUBE3D: "CUBE 3D",
    GameType.Moba: "HEROES MOBA",
    GameType.DeathMatch: "COUNTER STRIKE",
    GameType.SWARM: "SWARM",
    GameType.RANDOM: "PRACTICE",
    GameType.RANDOM_SOLO: "PLAY",
};

const freeToPlay = [
    GameType.MMO,
    GameType.Moba,
    GameType.BATTLE_ROYAL,
];