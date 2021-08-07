enum Tile {
  Concrete,
  Grass,
  Water
}

enum CharacterState { Idle, Walking, Dead, Aiming, Firing, Striking, Running }

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