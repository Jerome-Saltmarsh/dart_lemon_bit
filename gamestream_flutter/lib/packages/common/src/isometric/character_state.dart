class CharacterState {
  static const Idle = 0;
  static const Running = 1;
  static const Strike = 2;
  static const Changing = 3;
  static const Stunned = 4;
  static const Spawning = 5;
  static const Hurt = 6;
  static const Dead = 7;
  static const Aiming = 8;
  static const Fire = 9;
  static const Casting = 10;

  static String getName(int value) => const {
      Idle: 'Idle',
      Running: 'Running',
      Dead: 'Dead',
      Changing: 'Changing',
      Strike: 'Strike',
      Hurt: 'Hurt',
      Stunned: 'Stunned',
      Spawning: 'Spawning',
      Aiming: 'Aiming',
      Fire: 'Fire',
      Casting: 'Casting',
    }[value] ?? 'unknown-$value';
}
