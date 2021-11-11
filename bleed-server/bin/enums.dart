import 'common/Tile.dart';

// can a person pass through this tile
const Map<Tile, bool> _walkableTiles = {
  Tile.Grass: true,
  Tile.Grass02: true,
  Tile.Flowers: true,
  Tile.Long_Grass: true,
  Tile.ZombieSpawn: true,
  Tile.Concrete: true,
  Tile.Concrete_Vertical: true,
  Tile.Concrete_Horizontal: true,
  Tile.PlayerSpawn: true,
  Tile.Bridge: true,
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

bool isBulletCollideable(Tile tile){
  return !isShootable(tile);
}

enum CharacterState { Idle, Walking, Dead, Aiming, Firing, Striking, Running, Reloading, ChangingWeapon }

enum Direction {
  Up,
  UpRight,
  Right,
  DownRight,
  Down,
  DownLeft,
  Left,
  UpLeft,
  None
}

enum ParticleType {
  Blood,
  Shell,
  Head,
  Arm,
  Organ,
  Smoke
}