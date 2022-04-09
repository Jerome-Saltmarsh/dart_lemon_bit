import 'common/Tile.dart';

/// can a person pass through this tile
const _walkableTiles = <Tile, bool>{
  Tile.Grass: true,
  Tile.Flowers: true,
  Tile.Long_Grass: true,
  Tile.ZombieSpawn: true,
  Tile.Concrete: true,
  Tile.Bridge: true,
  Tile.Wooden_Floor: true,
  Tile.Rock: true,
};

bool isShootable(Tile tile) {
  const shootableTiles = <Tile, bool>{
    Tile.Water: true,
    ..._walkableTiles,
  };
  return shootableTiles.containsKey(tile);
}

bool isWalkable(Tile tile){
  return _walkableTiles.containsKey(tile);
}



