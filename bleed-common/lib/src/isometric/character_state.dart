class CharacterState {
  static const Idle       = 0;
  static const Running    = 1;
  static const Changing   = 2;
  static const Performing = 3;
  static const Stunned    = 4;
  static const Spawning   = 5;
  static const Hurt       = 6;
  static const Dead       = 7;
  
  static String getName(int value){
    return const {
      Idle: 'Idle',
      Running: 'Running',
      Dead: 'Dead',
      Changing: 'Changing',
      Performing: 'Performing',
      Hurt: 'Hurt',
      Stunned: 'Stunned',
      Spawning: 'Spawning',
    }[value] ?? 'unknown-$value';
  }
}
