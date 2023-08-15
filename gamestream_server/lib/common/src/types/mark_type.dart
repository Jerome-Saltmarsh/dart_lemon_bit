
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


  static int getIndex(int markValue) => markValue & 0xFFFF;

  static int getType(int markValue) => (markValue >> 16) & 0xFF;
}