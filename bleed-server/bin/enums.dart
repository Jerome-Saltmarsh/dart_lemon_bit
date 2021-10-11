import 'common/Tile.dart';

List<Tile> _closedTiles = [
  Tile.Water,
  Tile.Block,
  Tile.Block_Horizontal,
  Tile.Block_Vertical,
  Tile.Block_Corner_01,
  Tile.Block_Corner_02,
  Tile.Block_Corner_03,
  Tile.Block_Corner_04,
];

bool isOpen(Tile tile){
  return !_closedTiles.contains(tile);
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