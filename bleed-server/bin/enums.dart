import 'common/Tile.dart';

/// can a person pass through this tile
const Map<Tile, bool> _walkableTiles = {
  Tile.Grass: true,
  Tile.Flowers: true,
  Tile.Long_Grass: true,
  Tile.ZombieSpawn: true,
  Tile.Concrete: true,
  Tile.Concrete_Vertical: true,
  Tile.Concrete_Horizontal: true,
  Tile.Bridge: true,
  Tile.Wooden_Floor: true,
  Tile.Rock: true,
};

/// Can a bullet travel through this tile
const Map<Tile, bool> _shootableTiles = {
  Tile.Water: true,
  ..._walkableTiles,
};

bool isShootable(Tile tile){
  return _shootableTiles.containsKey(tile);
}

bool isWalkable(Tile tile){
  return _walkableTiles.containsKey(tile);
}

bool isProjectileCollideable(Tile tile){
  return !isShootable(tile);
}


