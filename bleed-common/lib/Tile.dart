
enum Tile {
  Concrete,
  Grass,
  Wooden_Floor,
  Long_Grass,
  Flowers,
  Water,
  Boundary,
  ZombieSpawn,
  RandomItemSpawn,
  Block,
  Block_Horizontal,
  Block_Vertical,
  Bridge,
  Rock,
  Black,
  Rock_Wall,
  Block_Grass,
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

const tiles = Tile.values;

const tileBoundary = Tile.Boundary;

String parseTileToString(Tile tile){
  return tile.toString().replaceAll("Tile.", "");
}

List<List<Tile>> mapJsonToTiles(dynamic json){
  final List<List<Tile>> rows = [];
  for(var jsonRow in json){
    final List<Tile> column = [];
    rows.add(column);
    for(var jsonColumn in jsonRow){
      final Tile tile = parseStringToTile(jsonColumn);
      column.add(tile);
    }
  }
  return rows;
}

Tile parseStringToTile(String text){
  return tiles.firstWhere((tile) => parseTileToString(tile) == text, orElse: (){
    throw Exception("could not parse $text to tile");
  });
}

int getRow(double x, double y){
  return (x + y) ~/ 48.0;
}

int getColumn(double x, double y){
  return (y - x) ~/ 48.0;
}


