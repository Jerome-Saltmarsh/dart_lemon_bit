
enum Tile {
  Concrete,
  Grass,
  Grass02,
  Wooden_Floor,
  Long_Grass,
  Flowers,
  Water,
  Boundary,
  Fortress,
  PlayerSpawn,
  ZombieSpawn,
  RandomItemSpawn,
  Block,
  Block_Horizontal,
  Block_Vertical,
  Concrete_Horizontal,
  Concrete_Vertical,
  Bridge,
  Rock,
  Black,
  Rock_Wall
}

final List<Tile> tiles = Tile.values;


String parseTileToString(Tile tile){
  return tile.toString().replaceAll("Tile.", "");
}

List<Tile> _blocks = [
  Tile.Block,
  Tile.Block_Horizontal,
  Tile.Block_Vertical,
];

List<Tile> _water = [
  Tile.Water,
];

bool isBlock(Tile tile){
  return _blocks.contains(tile);
}

bool isWater(Tile tile){
  return _water.contains(tile);
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