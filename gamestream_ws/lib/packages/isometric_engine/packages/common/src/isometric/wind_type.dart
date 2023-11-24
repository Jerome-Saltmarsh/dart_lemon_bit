
class WindType {
  static const Calm = 0;
  static const Gentle = 1;
  static const Strong = 2;

  static const values = [
    Calm, Gentle, Strong,
  ];
  
  static String getName(int windType) => const {
      Calm: 'Calm',
      Gentle: 'Gentle',
      Strong: 'Strong',
  }[windType] ?? 'wind-type-unknown-$windType';
}