enum Tile {
  Concrete,
  Grass,
  Water,
  Boundary,
  Fortress,
  PlayerSpawn,
  ZombieSpawn,
  RandomItemSpawn,
  Block,
  Block_Horizontal,
  Block_Vertical,
  Block_Corner_01,
  Block_Corner_02,
  Block_Corner_03,
  Block_Corner_04,
  Crate,
  Water_Side_01,
  Water_Side_02,
  Water_Side_03,
  Water_Side_04,
  Water_Corner_01,
  Water_Corner_02,
  Water_Corner_03,
  Water_Corner_04,
  Long_Grass,
  Flowers,
  Grass02,
  Concrete_Horizontal,
  Concrete_Vertical,
}

final List<Tile> tiles = Tile.values;

List<Tile> _blocks = [
  Tile.Block,
  Tile.Block_Horizontal,
  Tile.Block_Vertical,
];

bool isBlock(Tile tile){
  return _blocks.contains(tile);
}