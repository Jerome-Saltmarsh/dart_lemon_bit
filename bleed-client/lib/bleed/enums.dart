enum Tile {
  Concrete,
  Grass,
  Water
}

enum Weapon { Unarmed, HandGun, Shotgun }

enum GameEventType {
  Handgun_Fired,
  Shotgun_Fired,
  Zombie_Hit,
  Zombie_Killed,
  Zombie_Target_Acquired,
  Bullet_Hole,
  Zombie_Strike,
  Player_Death
}

enum ParticleType {
  Blood,
  Shell,
  Head,
  Arm,
  Organ,
}