class CharacterState {
  static const Idle = 0;
  static const Running = 1;
  static const Strike_1 = 2;
  static const Strike_2 = 3;
  static const Changing = 4;
  static const Stunned = 5;
  static const Spawning = 6;
  static const Hurt = 7;
  static const Dead = 8;
  static const Aiming = 9;
  static const Fire = 10;
  static const Casting = 11;

  static const strikes = [
    Strike_1, Strike_2,
  ];

  static const supportsAction = [
    Fire,
    Strike_1,
    Strike_2,
  ];

  static String getName(int value) => const {
      Idle: 'Idle',
      Running: 'Running',
      Dead: 'Dead',
      Changing: 'Changing',
      Strike_1: 'Strike_1',
      Strike_2: 'Strike_2',
      Hurt: 'Hurt',
      Stunned: 'Stunned',
      Spawning: 'Spawning',
      Aiming: 'Aiming',
      Fire: 'Fire',
      Casting: 'Casting',
    }[value] ?? 'unknown-$value';
}
