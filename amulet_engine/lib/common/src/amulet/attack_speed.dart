import 'item_quality.dart';

enum AttackSpeed {
  Very_Slow(duration: 48),
  Slow(duration: 40),
  Fast(duration: 32),
  Very_Fast(duration: 24);

  final int duration;

  const AttackSpeed({required this.duration});

  static AttackSpeed fromDuration(int duration) {
    for (final value in values) {
      if (duration >= value.duration) {
        return value;
      }
    }
    return AttackSpeed.values.last;
  }

  static int getPointTargetShoes({
    required int level,
    required ItemQuality quality,
  }) =>
      const {
        ItemQuality.Common: {
          1: 5,
          2: 10,
          3: 16,
        },
        ItemQuality.Unique: {
          1: 7,
          2: 13,
          3: 18,
        },
      }[quality]?[level] ??
          0;
}
