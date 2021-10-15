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
}

final List<Tile> tiles = Tile.values;