
class MarkType {
  static const Spawn_Player = 0;
  static const Spawn_Fallen = 1;
  static const Spawn_Whisp = 2;

  static const values = [
    Spawn_Player,
    Spawn_Fallen,
    Spawn_Whisp,
  ];

  static getName(int markType) => const {
      Spawn_Player: 'Spawn Player',
      Spawn_Fallen: 'Spawn Fallen',
      Spawn_Whisp: 'Spawn Whisp',
    }[markType] ?? (throw Exception('MarkType.getName($markType)'));
}