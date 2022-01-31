enum Phase {
  EarlyMorning,
  Morning, // 5 - 9
  Day, // 9 - 5
  EarlyEvening,
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