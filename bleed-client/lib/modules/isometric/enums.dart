enum Phase {
  Early_Morning,
  Morning, // 5 - 9
  Day, // 9 - 5
  Early_Evening,
  Evening, // 5 - 9
  Night, // 9
  MidNight, // - 5
}

final List<Phase> phases = Phase.values;

enum ParticleType {
  None,
  Smoke,
  Human_Head,
  Zombie_Head,
  Shell,
  Arm,
  Leg,
  Organ,
  Blood,
  Shrapnel,
  FireYellow,
  Myst,
  Pixel
}