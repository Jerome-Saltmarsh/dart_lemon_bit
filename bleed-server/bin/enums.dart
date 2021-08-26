enum Tile {
  Concrete,
  Grass,
  Water,
  Boundary,
  Fortress,
  PlayerSpawn,
  ZombieSpawn,
  RandomItemSpawn,
}


bool isOpen(Tile tile){
  if(tile == Tile.Grass) return false;
  if(tile == Tile.Boundary) return false;
  return true;
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