enum Tile {
  Concrete,
  Grass,
  Water
}

enum CharacterState { Idle, Walking, Dead, Aiming, Firing, Striking }

enum Weapon { Unarmed, HandGun, Shotgun }

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