
const tileNames = <int, String> {
   Tile.Concrete: "Concrete",
   Tile.Grass: "Grass",
   Tile.Wooden_Floor: "Wooden_Floor",
   Tile.Long_Grass: "Long_Grass",
   Tile.Flowers: "Flowers",
   Tile.Water: "Water",
   Tile.Boundary: "Boundary",
   Tile.ZombieSpawn: "ZombieSpawn",
   Tile.RandomItemSpawn: "RandomItemSpawn",
   Tile.Block: "Block",
   Tile.Block_Horizontal: "Block_Horizontal",
   Tile.Block_Vertical: "Block_Vertical",
   Tile.Bridge: "Bridge",
   Tile.Rock: "Rock",
   Tile.Black: "Black",
   Tile.Rock_Wall: "Rock_Wall",
   Tile.Block_Grass: "Block_Grass",
};

bool _loaded = false;
late Map<String, int> _nameTileInstance = {};

Map<String, int> get nameTiles {
  if (!_loaded){
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
  static const ZombieSpawn = 7;
  static const RandomItemSpawn = 8;
  static const Block = 9;
  static const Block_Horizontal = 10;
  static const Block_Vertical = 11;
  static const Bridge = 12;
  static const Rock = 13;
  static const Black = 14;
  static const Rock_Wall = 15;
  static const Block_Grass = 16;
}

const generatesObject = [
  Tile.Rock_Wall,
  Tile.Block_Grass,
  Tile.Block_Grass,
  Tile.Block_Vertical,
  Tile.Block_Horizontal,
  Tile.Block,
];

extension TileExtension on Tile {
  bool get isWater => this == Tile.Water;
  bool get isBoundary => this == Tile.Boundary;
}

const tileBoundary = Tile.Boundary;

List<List<int>> mapJsonToTiles(dynamic json){
  final List<List<int>> rows = [];
  for(var jsonRow in json){
    final List<int> column = [];
    rows.add(column);
    for(var jsonColumn in jsonRow){
      final int tile = parseStringToTile(jsonColumn);
      column.add(tile);
    }
  }
  return rows;
}

int parseStringToTile(String text){
  return nameTiles[text]!;
}

int getRow(double x, double y){
  return (x + y) ~/ 48.0;
}

int getColumn(double x, double y){
  return (y - x) ~/ 48.0;
}


