
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