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


enum GameEventType {
  Handgun_Fired,
  Shotgun_Fired,
  SniperRifle_Fired,
  MachineGun_Fired,
  Zombie_Hit,
  Zombie_Killed,
  Zombie_Target_Acquired,
  Bullet_Hole,
  Zombie_Strike,
  Player_Death,
  Explosion,
}

