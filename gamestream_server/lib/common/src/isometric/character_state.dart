class CharacterState {
  static const Idle       = 0;
  static const Running    = 1;
  static const Dead       = 2;
  static const Changing   = 3;
  static const Performing = 4;
  static const Hurt       = 5;
  static const Stunned    = 6;
  static const Spawning   = 7;
  
  static String getName(int value){
    return const {
      Idle: "Idle",
      Running: "Running",
      Dead: "Dead",
      Changing: "Changing",
      Performing: "Performing",
      Hurt: "Hurt",
      Stunned: "Stunned",
      Spawning: "Spawning",
    }[value] ?? 'unknown-$value';
  }
}
