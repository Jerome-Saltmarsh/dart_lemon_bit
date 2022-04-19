const tileNames = <int, String> {
  Tile.Concrete: "Concrete",
  Tile.Grass: "Grass",
  Tile.Wooden_Floor: "Wooden_Floor",
  Tile.Long_Grass: "Long_Grass",
  Tile.Flowers: "Flowers",
  Tile.Water: "Water",
  Tile.Boundary: "Boundary",
  Tile.Zombie_Spawn: "ZombieSpawn",
  Tile.Random_Item_Spawn: "RandomItemSpawn",
  Tile.Palisade: "Palisade",
  Tile.Bridge: "Bridge",
  Tile.Rock: "Rock",
  Tile.Black: "Black",
  Tile.Rock_Wall: "Rock_Wall",
  Tile.Block_Grass: "Block_Grass",
};

bool _loaded = false;
late Map<String, int> _nameTileInstance = {};

Map<String, int> get nameTiles {
  if (!_loaded) {
    tileNames.forEach((key, value) {
      _nameTileInstance[value] = key;
    });
    _loaded = true;
  }
  return _nameTileInstance;
}

class Tile {
  static const Concrete = 0;
  static const Grass = 1;
  static const Wooden_Floor = 2;
  static const Long_Grass = 3;
  static const Flowers = 4;
  static const Water = 5;
  static const Boundary = 6;
  static const Zombie_Spawn = 7;
  static const Random_Item_Spawn = 8;
  static const Palisade = 9;
  static const Bridge = 12;
  static const Rock = 13;
  static const Black = 14;
  static const Rock_Wall = 15;
  static const Block_Grass = 16;
  
  static String getName(int value) {
    return tileNames[value] ?? "?";
  }

  static const values = [
    Concrete,
    Grass,
    Wooden_Floor,
    Long_Grass,
    Flowers,
    Water,
    Boundary,
    Zombie_Spawn,
    Random_Item_Spawn,
    Palisade,
    Bridge,
    Rock,
    Black,
    Rock_Wall,
    Block_Grass,
  ];
}

const generatesObject = [
  Tile.Rock_Wall,
  Tile.Block_Grass,
  Tile.Block_Grass,
  Tile.Palisade,
];

extension TileExtension on Tile {
  bool get isWater => this == Tile.Water;

  bool get isBoundary => this == Tile.Boundary;
}

const tileBoundary = Tile.Boundary;

List<List<int>> mapJsonToTiles(dynamic json) {
  final List<List<int>> rows = [];
  for (var jsonRow in json) {
    final List<int> column = [];
    rows.add(column);
    for (var jsonColumn in jsonRow) {
      final int tile = parseStringToTile(jsonColumn);
      column.add(tile);
    }
  }
  return rows;
}

int parseStringToTile(String text) {
  return nameTiles[text]!;
}

int getRow(double x, double y) {
  return (x + y) ~/ 48.0;
}

int getColumn(double x, double y) {
  return (y - x) ~/ 48.0;
}


