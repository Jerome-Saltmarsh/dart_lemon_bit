enum GameType {
    Dark_Age,
    Editor,
    Arena,
    Waves,
}

const gameTypes = GameType.values;

const gameTypeNames = {
    GameType.Dark_Age: "DARK AGE",
    GameType.Editor: "MAP EDITOR",
    GameType.Arena: "ARENA",
    GameType.Waves: "WAVES",
};