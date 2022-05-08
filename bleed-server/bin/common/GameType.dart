enum GameType {
    None,
    MMO,
    Moba,
    BATTLE_ROYAL,
    SKIRMISH,
    RANDOM,
    PRACTICE,
    SWARM,
    DeathMatch,
    Custom
}


const gameTypes = GameType.values;

const gameTypeNames = {
    GameType.MMO: "ADVENTURE",
    GameType.SKIRMISH: "SKIRMISH",
    GameType.BATTLE_ROYAL: "ROYAL",
    GameType.Moba: "HEROES MOBA",
    GameType.DeathMatch: "COUNTER STRIKE",
    GameType.SWARM: "SWARM",
    GameType.PRACTICE: "PRACTICE",
    GameType.RANDOM: "THEY COME AT NIGHT",
};

const freeToPlay = [
    GameType.MMO,
    GameType.Moba,
    GameType.BATTLE_ROYAL,
];