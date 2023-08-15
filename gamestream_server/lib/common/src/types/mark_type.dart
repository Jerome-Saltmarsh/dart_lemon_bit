class MarkType {
  static const Whisp = 0;
  static const Spawn_Enemy = 1;
  static const Player_Spawn = 2;
  static const Mist = 3;
  static const Butterfly = 4;

  static const values = [
    Whisp,
    Spawn_Enemy,
    Player_Spawn,
    Mist,
    Butterfly,
  ];

  static String getName(int value) => const {
      Whisp: 'Whisp',
      Spawn_Enemy: 'Spawn Enemy',
      Player_Spawn: 'Player Spawn',
      Mist: 'Mist',
      Butterfly: 'Butterfly',
    }[value] ?? 'unknown-$value';
}
