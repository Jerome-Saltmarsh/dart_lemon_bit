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
  Crate,
  Concrete_Horizontal,
  Concrete_Vertical,
  Bridge,
  Rock,
  Black,
}

final List<Tile> tiles = Tile.values;

Tile parseStringToTile(String text){
  return tiles.firstWhere((element) => parseTileToString(element) == text, orElse: (){
    throw Exception("could not parse $text to tile");
  });
}

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