import 'common/Tile.dart';

List<Tile> _walkableTiles = [
  Tile.Grass,
  Tile.Grass02,
  Tile.Flowers,
  Tile.Long_Grass,
  Tile.ZombieSpawn,
  Tile.Concrete,
  Tile.Concrete_Vertical,
  Tile.Concrete_Horizontal,
  Tile.PlayerSpawn,
  Tile.Bridge
];

List<Tile> _closedTiles = [
  Tile.Water,
  Tile.Block,
  Tile.Block_Horizontal,
  Tile.Block_Vertical,
];

List<Tile> _collisionTiles = [
  Tile.Block,
  Tile.Block_Horizontal,
  Tile.Block_Vertical,
];

bool isWalkable(Tile tile){
  return _walkableTiles.contains(tile);
}

bool isOpen(Tile tile){
  return !_closedTiles.contains(tile);
}

bool isCollision(Tile tile){
  return _collisionTiles.contains(tile);
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