
/// a mark value is 32 bit integer comprised of two parts
/// the first two bytes are used to store the node index
/// the third byte is used to store the mark type
/// the fourth byte is used to store meta data associated with its mark type
class MarkType {
  static const Spawn_Player = 0;
  static const Spawn_Fallen = 1;
  static const Spawn_Whisp = 2;
  static const Spawn_Myst = 3;
  static const Glow = 4;
  static const Butterfly = 5;

  static const values = [
    Spawn_Player,
    Spawn_Fallen,
    Spawn_Whisp,
    Spawn_Myst,
    Glow,
    Butterfly,
  ];

  static String getTypeName(int markValue) => getName(getType(markValue));

  static int build({required int index, required int type}) =>
      index | type << 16;

  static getName(int markType) => const {
    Spawn_Player: 'Spawn Player',
    Spawn_Fallen: 'Spawn Fallen',
    Spawn_Whisp: 'Spawn Whisp',
    Spawn_Myst: 'Spawn Myst',
    Glow: 'Glow',
    Butterfly: 'Butterfly',
  }[markType] ?? (throw Exception('MarkType.getName($markType)'));

  static int getIndex(int markValue) => markValue & 0xFFFF;

  static int getType(int markValue) => (markValue >> 16) & 0xFF;
}