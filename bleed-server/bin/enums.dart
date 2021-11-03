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
  Tile.Water_Corner_01,
  Tile.Water_Corner_02,
  Tile.Water_Corner_03,
  Tile.Water_Corner_04,
  Tile.Water_Side_01,
  Tile.Water_Side_02,
  Tile.Water_Side_03,
  Tile.Water_Side_04,
  Tile.Block,
  Tile.Block_Horizontal,
  Tile.Block_Vertical,
  Tile.Block_Corner_01,
  Tile.Block_Corner_02,
  Tile.Block_Corner_03,
  Tile.Block_Corner_04,
];

List<Tile> _collisionTiles = [
  Tile.Block,
  Tile.Block_Horizontal,
  Tile.Block_Vertical,
  Tile.Block_Corner_01,
  Tile.Block_Corner_02,
  Tile.Block_Corner_03,
  Tile.Block_Corner_04,
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