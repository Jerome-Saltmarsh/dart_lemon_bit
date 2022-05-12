enum GameType {
    RANDOM,
    SURVIVORS,
}

const gameTypes = GameType.values;

const gameTypeNames = {
    GameType.RANDOM: "PLAY",
    GameType.SURVIVORS: "SURVIVORS",
};