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

enum GameEventType {
  Handgun_Fired,
  Shotgun_Fired,
  Zombie_Hit,
  Zombie_Killed,
  Zombie_Target_Acquired
}