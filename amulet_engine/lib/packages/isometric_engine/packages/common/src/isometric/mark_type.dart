
/// a mark value is 32 bit integer comprised of two parts
/// the first two bytes are used to store the node index
/// the third byte is used to store the mark type
/// the fourth byte is used to store meta data associated with its mark type
class MarkType {
  static const Fiend = 1;
  static const Whisp = 2;
  static const Myst = 3;
  static const Glow = 4;
  static const Butterfly = 5;
  static const Moth = 6;
  static const Water_Drops = 7;
  static const Windy = 8;

  static const values = [
    Fiend,
    Whisp,
    Myst,
    Glow,
    Butterfly,
    Moth,
    Water_Drops,
    Windy,
  ];

  static String getTypeName(int markValue) => getName(getType(markValue));

  static int build({
    required int index,
    required int type,
    int subType = 0,
  }) =>
      index | type << 16 | subType << 24;

  static getName(int markType) => const {
    Fiend: 'Fiend',
    Whisp: 'Whisp',
    Myst: 'Myst',
    Glow: 'Glow',
    Butterfly: 'Butterfly',
    Moth: 'Moth',
    Water_Drops: 'Water_Drops',
    Windy: 'Windy',
  }[markType] ?? 'unknown-$markType';

  static int getIndex(int markValue) => markValue & 0xFFFF;

  static int getType(int markValue) => (markValue >> 16) & 0xFF;

  static int getSubType(int markValue) => (markValue >> 24) & 0xFF;
}