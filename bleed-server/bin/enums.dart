import 'common/Tile.dart';

/// can a person pass through this tile
const _walkableTiles = <int, bool>{
  Tile.Grass: true,
  Tile.Flowers: true,
  Tile.Long_Grass: true,
  Tile.Zombie_Spawn: true,
  Tile.Concrete: true,
  Tile.Bridge: true,
  Tile.Wooden_Floor: true,
  Tile.Rock: true,
};

bool isShootable(int tile) {
  const shootableTiles = <int, bool>{
    Tile.Water: true,
    ..._walkableTiles,
  };
  return shootableTiles.containsKey(tile);
}

bool isWalkable(int tile){
  return _walkableTiles.containsKey(tile);
}



