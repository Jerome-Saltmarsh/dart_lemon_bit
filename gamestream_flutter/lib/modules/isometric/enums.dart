enum Phase {
  Early_Morning,
  Morning, // 5 - 9
  Day, // 9 - 5
  Early_Evening,
  Evening, // 5 - 9
  Night, // 9
  MidNight, // - 5
}

const phases = Phase.values;

class ParticleType {
  static const Smoke = 0;
  static const Human_Head = 1;
  static const Zombie_Head = 2;
  static const Shell = 3;
  static const Arm = 4;
  static const Leg = 5;
  static const Organ = 6;
  static const Blood = 7;
  static const Shrapnel = 8;
  static const FireYellow = 9;
  static const Myst = 10;
  static const Pixel = 11;
  static const Orb_Ruby = 12;
  static const Pot_Shard = 13;
}
